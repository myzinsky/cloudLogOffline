#ifndef RBMODEL_H
#define RBMODEL_H

#include <QAbstractListModel>
#include <QByteArray>
#include <QElapsedTimer>
#include <QGeoCoordinate>
#include <QDateTime>
#include <QSettings>
#include <QString>

QT_BEGIN_NAMESPACE
class QGeoPositionInfo;
class QGeoPositionInfoSource;
class QNetworkAccessManager;
class QNetworkReply;
QT_END_NAMESPACE


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
    void locatorDone(const QString &locator);

public slots:
    QString getLocator();
    void getRepeaters();
    void tryStartPositioning();
    void tryStartPositioning(const QString& oldLocator);
    void stopPositioning();
    
private:
    void startPositioning();
    
    bool refreshModel(const QByteArray &rawData);
    
private Q_SLOTS:
    void positionUpdated(const QGeoPositionInfo &info);
    void parseNetworkResponse(QNetworkReply* nreply);
    
private:
    QList<relais> database;
    QString locator;
    QGeoCoordinate coord;
    
    QGeoPositionInfoSource *source = nullptr;
    QNetworkAccessManager *nm = nullptr;
    QElapsedTimer request_timer;
    
protected:
    QSettings settings;
};

#endif // RBMODEL_H
