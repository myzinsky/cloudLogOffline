#include "repeatermodel.h"

#include <QCoreApplication>

#include "maidenhead.h"


#if QT_VERSION >= QT_VERSION_CHECK(6, 5, 0) && QT_CONFIG(permissions)
#  define CLO_HAVE_QPERMISSION
#  include <QPermissions>
#endif


rbManager::rbManager(QObject *parent)
    : QAbstractListModel(parent)
{
    nm = nullptr;
    initialized = false;
}

rbManager::~rbManager()
{
    if(nm != nullptr) {
        delete nm;
    }
}

void rbManager::init()
{
    if(initialized == false) {
        qDebug() << "INIT";
        locator = "";
        initialized = true;

        source = QGeoPositionInfoSource::createDefaultSource(this);

        connect(source,
                SIGNAL(positionUpdated(QGeoPositionInfo)),
                this,
                SLOT(positionUpdated(QGeoPositionInfo)));

        source->setUpdateInterval(60*1000);
        source->startUpdates();
    }
}

void rbManager::checkPermissions()
{
#ifdef CLO_HAVE_QPERMISSION
    QLocationPermission preciselocationPermission;
    preciselocationPermission.setAccuracy(QLocationPermission::Precise);

    if(qApp->checkPermission(preciselocationPermission) != Qt::PermissionStatus::Granted) {
        qApp->requestPermission(preciselocationPermission, this, [this](const QPermission &permission) {
            if (permission.status() == Qt::PermissionStatus::Granted) {
                qDebug() << "PRECISE PERMISSION GRANTED";
                init();
            } else {
                qDebug() << "PRECISE PERMISSION NOT GRANTED";
            }
        });
    } else {
        qDebug() << "PRECISE PERMISSION ALREADY GRANTED";
        init();
    }
#endif
}

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

void rbManager::positionUpdated(const QGeoPositionInfo &info)
{
    qDebug() << "Position updated: " << info;
    locator = maidenhead::fromLatLon(info.coordinate());
    emit locatorDone(locator);
    getRepeaters();
}

void rbManager::getRepeaters()
{
    checkPermissions();
    if (!nm)
    {
        nm = new QNetworkAccessManager(this);
        connect(nm,
                SIGNAL(finished(QNetworkReply*)),
                this,
                SLOT(parseNetworkResponse(QNetworkReply*)));
    }

    //QString url = "https://www.repeaterbook.com/api/exportROW.php?country="+country;
    QString url = "https://hearham.com/api/repeaters/v1";
    nm->get(QNetworkRequest(QUrl(url)));
}

bool rbManager::filter(double rLat, double rLon, double radius)
{
    QGeoCircle circ(coord, 1000.0 * radius);
    QGeoCoordinate repeater(rLat,rLon);
    return circ.contains(repeater);
}

double rbManager::distance(double rLat, double rLon)
{
    QGeoCoordinate repeater(rLat,rLon);
    return repeater.distanceTo(coord)/1000.0;
}

QString rbManager::getLocator()
{
    return locator;
}

void rbManager::parseNetworkResponse(QNetworkReply *nreply) // from getRepeaters
{
    const QByteArray rawJson = nreply->readAll();
    const QJsonDocument jsonResponse = QJsonDocument::fromJson(rawJson);

    const QJsonArray jsonRepeaters = jsonResponse.array();

    beginResetModel();
    database.clear();

    double radius = settings.value("rbRadius").toDouble();
    if (radius <= 0.0)
        radius = 20.0;

    for (const auto& jsonRepeater : jsonRepeaters) {
        const QJsonObject repeater = jsonRepeater.toObject();
        double rlat = repeater["latitude"].toDouble();
        double rlon = repeater["longitude"].toDouble();

        if(filter(rlat, rlon, radius)) {
            qDebug() << "Found: " << repeater["callsign"].toString();
            relais r;
            r.call      = repeater["callsign"].toString();
            r.frequency = QString::number(repeater["frequency"].toDouble()/1000.0/1000.0);
            r.lat       = QString::number(rlat);
            r.lon       = QString::number(rlon);
            r.shift     = QString::number(repeater["offset"].toDouble()/1000.0/1000.0);
            r.distance  = distance(rlat, rlon);
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
}
