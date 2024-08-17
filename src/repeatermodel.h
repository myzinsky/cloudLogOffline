#ifndef RBMODEL_H
#define RBMODEL_H

#include <QGeoCoordinate>
#include <QGeoPositionInfoSource>
#include <QDebug>
#include <QGeoLocation>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QGeoCircle>
#include <QSettings>
#include <QAbstractListModel>
#include <QString>

struct relais {
    QString call;
    QString lat;
    QString lon;
    double  distance;
    QString frequency;
    QString shift;
    QString modes;
    QString tone;
    QString city;
};

class rbManager : public QAbstractListModel
{
    Q_OBJECT

    friend class MaidenheadTest;

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
    ~rbManager();
    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;
    QHash<int, QByteArray> roleNames() const;

signals:
    void locatorDone(const QString &locator);

public slots:
    QString getLocator();
    void getRepeaters();
    void checkPermissions();

private:
    QGeoPositionInfoSource *source;
    QNetworkAccessManager *nm;

    QString country;
    QString locator;
    QGeoCoordinate coord;
    bool initialized;
    bool filter(double rLat, double rLon, double radius);
    double distance(double rLat, double rLon);
    void calculateMaidenhead(double lat, double lon);
    void init();

    QList<relais> database;

private Q_SLOTS:
    void positionUpdated(const QGeoPositionInfo &info);
    void parseNetworkResponse(QNetworkReply* nreply);

protected:
    QSettings settings;
};

#endif // RBMODEL_H
