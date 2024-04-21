#ifndef RBMODEL_H
#define RBMODEL_H

#include <QByteArray>
#include <QGeoCoordinate>
#include <QGeoPositionInfoSource>
#include <QDateTime>
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
#include <QPermissions>
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
    
    // Qt list model interface
    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;
    QHash<int, QByteArray> roleNames() const;
    
    // Positioning and locator interface
signals:
    void locatorChanged(const QString &locator);

public slots:
    QString getLocator();
    void getRepeaters();
    void tryStartPositioning();
    void tryStartPositioning(const QString& oldLocator);
    void stopPositioning();

private:
    QGeoPositionInfoSource *source = nullptr;
    QNetworkAccessManager *nm = nullptr;

    QString country;
    QString locator;
    QGeoCoordinate coord;
    QByteArray raw_database;
    QDateTime raw_database_stamp;
    
    void startPositioning();
    
    bool refreshModel(const QByteArray &rawData);

    QList<relais> database;

private Q_SLOTS:
    void positionUpdated(const QGeoPositionInfo &info);
    void parseNetworkResponse(QNetworkReply* nreply);

protected:
    QSettings settings;
};

#endif // RBMODEL_H
