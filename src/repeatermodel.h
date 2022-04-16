#ifndef RBMODEL_H
#define RBMODEL_H

#include <QGeoCoordinate>
#include <QGeoPositionInfoSource>
#include <QDebug>
#include <QGeoCodingManager>
#include <QGeoServiceProvider>
#include <QGeoAddress>
#include <QGeoLocation>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QGeoCircle>
#include <QSettings>
#include <QAbstractListModel>

struct relais {
    QString call;
    QString lat;
    QString lon;
    QString distance;
    QString frequency;
    QString shift;
    QString modes;
    QString tone;
    QString city;
};

class rbManager : public QAbstractListModel
{
    Q_OBJECT

    enum Role {
        call = Qt::UserRole,
        lati,
        lond,
        dist,
        freq,
        shif,
        mode,
        tone,
        city
    };

public:
    rbManager(QObject *parent = nullptr);
    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;
    QHash<int, QByteArray> roleNames() const;

private:
    QGeoPositionInfoSource *source;
    QGeoServiceProvider *prov;
    QGeoCodingManager *geoCoder;
    QGeoCodeReply * reply;
    QNetworkAccessManager *nm;

    QString country;
    QGeoCoordinate coord;
    bool found;
    void getRepeaters(QString country);
    bool filter(double rLat, double rLon, double radius);
    double distance(double rLat, double rLon);

    QList<relais> database;

private Q_SLOTS:
    void positionUpdated(const QGeoPositionInfo &info);
    void positionDecoded();
    void parseNetworkResponse(QNetworkReply* nreply);

protected:
    QSettings settings;
};

#endif // RBMODEL_H
