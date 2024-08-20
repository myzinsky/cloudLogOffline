#include "repeatermodel.h"

#include <QCoreApplication>
#include <QDebug>
#include <QDir>
#include <QGeoCircle>
#include <QGeoPositionInfo>
#include <QGeoPositionInfoSource>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QFile>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QStandardPaths>

#include "cacheddata.h"
#include "maidenhead.h"


#if QT_VERSION >= QT_VERSION_CHECK(6, 5, 0) && QT_CONFIG(permissions)
#  define CLO_HAVE_QPERMISSION
#  include <QPermissions>
#endif


/**
 * Key behaviors
 *
 * Construction           -> empty model, empty locator, invalid cood
 * tryStartPositioning()  -> check permissions, start positioning if granted,
 *                           (optionally) init locator
 * positionUpdated()      -> update coord and locator (if moved more than threshold),
 *                           emit locatorDone on actual change,
 *                           refresh database on actual change or if empty
 * getLocator()           -> return current locator, init from settings if unknown
 * getRepeaters()         -> request update of repeater list (cache, network)
 * refreshModel()         -> update filtered database from full data and current position
 */


rbManager::rbManager(QObject *parent)
    : QAbstractListModel(parent)
{}

rbManager::~rbManager() = default;


// Qt list model interface

int rbManager::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return database.size();
}

QVariant rbManager::data(const QModelIndex &index, int role) const
{
    if (index.isValid()) {

        switch(role)
        {
            case call: return database[index.row()].call;
            case lati: return database[index.row()].lat;
            case lond: return database[index.row()].lon;
            case dist: return QString::number(database[index.row()].distance);
            case freq: return database[index.row()].frequency;
            case shif: return database[index.row()].shift;
            case tone: return database[index.row()].tone;
            case mode: return database[index.row()].modes;
            case city: return database[index.row()].city;
        }
    }
    return QVariant();
}

QHash<int, QByteArray> rbManager::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[call] = "call";
    roles[lati] = "lati";
    roles[lond] = "lond";
    roles[dist] = "dist";
    roles[freq] = "freq";
    roles[shif] = "shif";
    roles[tone] = "tone";
    roles[mode] = "mode";
    roles[city] = "city";
    return roles;
}


// Positioning

void rbManager::tryStartPositioning()
{
    tryStartPositioning(locator);
}

void rbManager::tryStartPositioning(const QString& oldLocator)
{
    locator = oldLocator;
    coord = maidenhead::toGeoCoordinate(locator);
    
#ifdef CLO_HAVE_QPERMISSION
    QLocationPermission preciselocationPermission;
    preciselocationPermission.setAccuracy(QLocationPermission::Precise);

    if(qApp->checkPermission(preciselocationPermission) != Qt::PermissionStatus::Granted) {
        qApp->requestPermission(preciselocationPermission, this, [this](const QPermission &permission) {
            if (permission.status() == Qt::PermissionStatus::Granted) {
                qDebug() << "PRECISE PERMISSION GRANTED";
                startPositioning();
            } else {
                qDebug() << "PRECISE PERMISSION NOT GRANTED";
            }
        });
    }
    
    qDebug() << "PRECISE PERMISSION ALREADY GRANTED";
#else
    qDebug() << "PRECISE PERMISSION NOT IMPLEMENTED";
#endif
    startPositioning();
}

void rbManager::startPositioning()
{
    if (source)
        return;

    source = QGeoPositionInfoSource::createDefaultSource(this);
    if (source)
    {
        qDebug("INIT positioning, source: %s", qUtf8Printable(source->sourceName()));
        connect(source, &QGeoPositionInfoSource::positionUpdated, this, &rbManager::positionUpdated);
        source->setUpdateInterval(60*1000);
        source->startUpdates();
    } else {
        qDebug("INIT positioning failed");
    }
}

void rbManager::stopPositioning()
{
    if (source)
    {
        source->stopUpdates();
        source->deleteLater();
        source = nullptr;
    }
}

void rbManager::positionUpdated(const QGeoPositionInfo &info)
{
    qDebug() << "Position updated: " << info;
    if (!coord.isValid() || coord.distanceTo(info.coordinate()) >= 2)  // threshold: 2 m
    {
        coord = info.coordinate();
        auto new_locator = maidenhead::fromGeoCoordinate(coord);
        if (new_locator != locator)
        {
            locator = new_locator;
            emit locatorDone(locator);
            getRepeaters();
        }
        else if(database.isEmpty())
        {
            getRepeaters();
        }
    }
}

QString rbManager::getLocator()
{
    if (locator.isEmpty())
    {
        const auto gridsquare = settings.value("gridsquare").toString();
        const auto approximate_coord = maidenhead::toGeoCoordinate(gridsquare);
        if (approximate_coord.isValid())
        {
            coord = approximate_coord;
            locator = gridsquare;
            emit locatorDone(locator);
        }
    }
    return locator;
}


// Repeater list initialization and refresh

void rbManager::getRepeaters()
{
    QByteArray cachedData;
    const auto max_age = 24*3600; // 24 h
    if (cachedData::restore("repeaters", cachedData, max_age))
    {
        refreshModel(cachedData);
        return;
    }

    // Use network.
    if (!nm)
    {
        nm = new QNetworkAccessManager(this);
        connect(nm, &QNetworkAccessManager::finished, this, &rbManager::parseNetworkResponse);
    }
    else if (request_timer.isValid() && request_timer.elapsed() < 60*1000 /*milliseconds*/)
    {
        return;  // rate limiting
    }
    QNetworkRequest request(QUrl("http://hearham.com/api/repeaters/v1"));
    request.setHeader(QNetworkRequest::UserAgentHeader, "CloudLogOffline/" GIT_VERSION);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    nm->get(request);
}

void rbManager::parseNetworkResponse(QNetworkReply* nreply)
{
    request_timer.invalidate();
    const QByteArray rawData = nreply->readAll();
    if (refreshModel(rawData))
        cachedData::save("repeaters", rawData);
}

bool rbManager::refreshModel(const QByteArray& rawData)
{
    const QJsonDocument jsonResponse = QJsonDocument::fromJson(rawData);
    if (jsonResponse.isNull())
        return false;
        
    beginResetModel();
    database.clear();

    double radius = settings.value("rbRadius").toDouble();
    if (radius <= 0.0)
        radius = 20.0;
    const QGeoCircle neighborhood(coord, 1000.0 * radius);
    
    const QJsonArray jsonRepeaters = jsonResponse.array();
    for (const auto& jsonRepeater : jsonRepeaters) {
        const QJsonObject repeater = jsonRepeater.toObject();
        double rlat = repeater["latitude"].toDouble();
        double rlon = repeater["longitude"].toDouble();
        auto repeaterCoord = QGeoCoordinate(rlat, rlon); 

        if (neighborhood.contains(repeaterCoord)) {
            qDebug() << "Found: " << repeater["callsign"].toString();
            relais r;
            r.call      = repeater["callsign"].toString();
            r.frequency = QString::number(repeater["frequency"].toDouble()/1000.0/1000.0);
            r.lat       = QString::number(rlat);
            r.lon       = QString::number(rlon);
            r.shift     = QString::number(repeater["offset"].toDouble()/1000.0/1000.0);
            r.distance  = coord.distanceTo(repeaterCoord) / 1000.0;
            r.tone      = repeater["decode"].toString();
            r.city      = repeater["city"].toString().split(QLatin1Char(','))[0];
            r.modes     = repeater["mode"].toString();
            database.append(r);
        }
    }

    std::sort(database.begin(), database.end(), [](const relais &a, const relais &b) {
        return a.distance < b.distance;
    });

    endResetModel();
    return true;
}
