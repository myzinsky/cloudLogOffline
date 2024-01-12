#include "repeatermodel.h"

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

        nm = new QNetworkAccessManager(this);
        connect(nm,
                SIGNAL(finished(QNetworkReply*)),
                this,
                SLOT(parseNetworkResponse(QNetworkReply*)));
    }
}

void rbManager::precisePermissionUpdated(const QPermission &permission) {
    if (permission.status() == Qt::PermissionStatus::Granted) {
        qDebug() << "PRECISE PERMISSION GRANTED";
        init();
    } else {
        qDebug() << "PRECISE PERMISSION NOT GRANTED";
    }
}

void rbManager::checkPermissions()
{
    QLocationPermission preciselocationPermission;
    preciselocationPermission.setAccuracy(QLocationPermission::Precise);

    if(qApp->checkPermission(preciselocationPermission) != Qt::PermissionStatus::Granted) {
        qApp->requestPermission(QLocationPermission{}, this, &rbManager::precisePermissionUpdated);
    } else {
        qDebug() << "PRECISE PERMISSION ALREADY GRANTED";
        init();
    }
}

int rbManager::rowCount(const QModelIndex &parent) const
{
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
    coord = info.coordinate();
    calculateMaidenhead(coord.latitude(), coord.longitude());
    getRepeaters();
}

void rbManager::getRepeaters()
{
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

void rbManager::calculateMaidenhead(double lat, double lon)
{
    QString alphabet = "ABCDEFGHIJKLMNOPQRSTUVWX";

    lat = lat + 90.0;
    lon = lon + 180.0;

    QString grid_lat_sq = alphabet.at(int(lat/10));
    QString grid_lon_sq = alphabet.at(int(lon/20));
    QString grid_lat_field = QString::number(int(lat)%10);
    QString grid_lon_field = QString::number(int((lon/2))%10);
    double lat_remainder = (lat - int(lat)) * 60;
    double lon_remainder = ((lon) - int(lon/2)*2) * 60;
    QString grid_lat_subsq = alphabet.at(int(lat_remainder/2.5));
    QString grid_lon_subsq = alphabet.at(int(lon_remainder/5));

    locator = grid_lon_sq + grid_lat_sq + grid_lon_field + grid_lat_field + grid_lon_subsq + grid_lat_subsq;
    emit locatorDone(locator);
}

QString rbManager::getLocator()
{
    return locator;
}

void rbManager::parseNetworkResponse(QNetworkReply *nreply) // from getRepeaters
{
    QString rawJson = nreply->readAll();
    QJsonDocument jsonResponse = QJsonDocument::fromJson(rawJson.toUtf8());
    QJsonObject json = jsonResponse.object();

    QJsonArray repeaters = jsonResponse.array();

    beginResetModel();
    database.clear();

    for(auto repeater : repeaters) {
        relais r;
        double rlat = repeater.toObject()["latitude"].toDouble();
        double rlon = repeater.toObject()["longitude"].toDouble();

        double radius = settings.value("rbRadius").toString().toDouble();

        if(filter(rlat, rlon, radius)) {
            qDebug() << "Found: " << repeater.toObject()["callsign"].toString();
            r.call      = repeater.toObject()["callsign"].toString();
            r.frequency = QString::number(repeater.toObject()["frequency"].toDouble()/1000.0/1000.0);
            r.lat       = QString::number(rlat);
            r.lon       = QString::number(rlon);
            r.shift     = QString::number(repeater.toObject()["offset"].toDouble()/1000.0/1000.0);
            r.distance  = distance(rlat, rlon);
            r.tone      = repeater.toObject()["decode"].toString();
            r.city      = repeater.toObject()["city"].toString().split(QLatin1Char(','))[0];
            r.modes     = repeater.toObject()["mode"].toString();
            database.append(r);
        }
    }

    std::sort(database.begin(), database.end(), [](relais a, relais b) {
        return a.distance < b.distance;
    });

    endResetModel();
}
