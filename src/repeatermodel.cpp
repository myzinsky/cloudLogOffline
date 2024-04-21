#include "repeatermodel.h"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QStandardPaths>

#if QT_VERSION >= QT_VERSION_CHECK(6, 5, 0)
#  define CLO_HAVE_QPERMISSION
#  include <QPermission>
#endif

namespace {

QString calculateMaidenhead(double lat, double lon)
{
    static const QString alphabet = "ABCDEFGHIJKLMNOPQRSTUVWX";
    static const QString numbers = "0123456789";

    lat = qBound(0.0, lat + 90.0, 180.0);
    lon = qBound(0.0, lon + 180.0, 360.0);

    QString result {6, QChar::Space};
    result[0] = alphabet.at(int(lon/20));
    result[1] = alphabet.at(int(lat/10));
    result[2] = numbers.at(int((lon/2))%10);
    result[3] = numbers.at(int(lat)%10);
    double lat_remainder = (lat - int(lat)) * 60;
    double lon_remainder = ((lon) - int(lon/2)*2) * 60;
    result[4] = alphabet.at(int(lon_remainder/5));
    result[5] = alphabet.at(int(lat_remainder/2.5));
    return result;
}

QGeoCoordinate fromMaidenhead(QString gridsquare)
{
    if (gridsquare.isEmpty())
        return {};
    
    const auto bytes = gridsquare.toUpper().toUtf8();
    double lat = (bytes[1] - 'A') * 10 + (bytes[3] - '0')     + (bytes[5] - 'A' + 0.5) * 2.5 / 60.0 - 90.0;
    double lon = (bytes[0] - 'A') * 20 + (bytes[2] - '0') * 2 + (bytes[4] - 'A' + 0.5) * 5.0 / 60.0 - 180.0;
    return { lat, lon };
}


bool saveToCache(const QString& identifier, const QByteArray& data)
{
    const auto cache_dir = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    if (!cache_dir.isEmpty() && QDir::root().mkpath(cache_dir))
    {
        auto file = QFile(cache_dir + '/' + identifier);
        file.open(QIODevice::WriteOnly | QIODevice::Truncate) && file.write(data);
        if (!file.error())
        {
            qDebug("SAVED %s to %s", qPrintable(identifier), qPrintable(cache_dir));
            return true;
        }
    }
    return false;
}

bool restoreFromCache(const QString& identifier, QByteArray &data)
{
    const auto cache_dir = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    auto file = QFile(cache_dir + '/' + identifier);
    if (!cache_dir.isEmpty() && file.open(QIODevice::ReadOnly))
    {
        auto buffer = file.readAll();
        if (!file.error())
        {
            data = buffer;
            qDebug("RESTORED %s from %s", qPrintable(identifier), qPrintable(cache_dir));
            return true;
        }
    }
    return false;
}

}  // namespace


/**
 * Key behaviors
 *
 * Construction           -> empty model, empty locator, invalid data stamp
 * tryStartPositioning()  -> check permissions, start positioning if granted,
 *                           (optionally) init locator
 * positionUpdated()      -> update coord and locator (if moved more that 50 m),
 *                           emit locatorChanged on actual change
 * getLoctor()            -> return current locator, init from settings if unknown
 * getRepeaters()         -> request acquisition of repeater list (memory, disk, net)
 * requestDatabase()      -> start networkmanager, start network request
 * refreshModel()         -> update filtered data from full data and position
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
    if (!coord.isValid() || coord.distanceTo(info.coordinate()) >= 50)  // threshold: 50 m
    {
        coord = info.coordinate();
        auto new_locator = calculateMaidenhead(coord.latitude(), coord.longitude());
        if (new_locator != locator)
        {
            locator = new_locator;
            emit locatorChanged(locator);
        }
        refreshModel(raw_database);
    }
}

QString rbManager::getLocator()
{
    if (locator.isEmpty())
    {
        const auto gridsquare = settings.value("gridsquare").toString();
        const auto approximate_coord = fromMaidenhead(gridsquare);
        if (approximate_coord.isValid())
        {
            coord = approximate_coord;
            locator = gridsquare;
            emit locatorChanged(locator);
        }
    }
    return locator;
}


// Repeater list initialization and refresh

void rbManager::getRepeaters()
{
    const auto accept_stamp = [](auto& stamp) -> bool {
        return stamp.isValid() && qAbs(stamp.secsTo(QDateTime::currentDateTimeUtc())) < 12*3600; // 12 h
    };
    
    // Use loaded unfiltered data as-is?
    if (accept_stamp(raw_database_stamp))
    {
        refreshModel(raw_database);
        return;
    }
    
    // Use cache file
    const auto cache_stamp = settings.value("rbCacheStamp").toDateTime();
    if (accept_stamp(cache_stamp) && restoreFromCache("repeaters", raw_database))
    {
        // memory changed from disk
        raw_database_stamp = cache_stamp;
        refreshModel(raw_database);
        return;
    }
    
    // Use network.
    if (!nm)
    {
        nm = new QNetworkAccessManager(this);
        connect(nm, &QNetworkAccessManager::finished, this, &rbManager::parseNetworkResponse);
    }
    QNetworkRequest request(QUrl("http://hearham.com/api/repeaters/v1"));
    request.setHeader(QNetworkRequest::UserAgentHeader, "CloudLogOffline/" GIT_VERSION);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    nm->get(request);
}

void rbManager::parseNetworkResponse(QNetworkReply* nreply)
{
    const QByteArray rawData = nreply->readAll();
    if (refreshModel(rawData))
    {
        raw_database = rawData;
        raw_database_stamp = QDateTime::currentDateTimeUtc();
        if (saveToCache("repeaters", raw_database))
            settings.setValue("rbCacheStamp", raw_database_stamp);
    }
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
