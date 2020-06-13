#ifndef QRZMANAGER_H
#define QRZMANAGER_H
#include <QObject>
#include <QSettings>
#include <QDebug>
#include <QNetworkReply>
#include <QXmlStreamReader>

class qrzManager : public QObject
{
    Q_OBJECT

public:
    qrzManager(QObject *parent = 0);

public slots:
    void lookupCall(QString call);
    void keyManagerFinished(QNetworkReply *reply);
    void queryManagerFinished(QNetworkReply *reply);
    void receiveKey();

signals:
    void qrzDone(const QString &fname,
                 const QString &name,
                 const QString &addr1,
                 const QString &addr2,
                 const QString &zip,
                 const QString &country,
                 const QString &qslmgr,
                 const QString &locator,
                 const QString &lat,
                 const QString &lon,
                 const QString &license,
                 const QString &cqzone,
                 const QString &ituzone,
                 const QString &born,
                 const QString &image);
    void qrzFail(const QString &error);

private:
    QSettings settings;
    QNetworkAccessManager *keyManager;
    QNetworkAccessManager *queryManager;
    QNetworkRequest request;

    QString parseXML(QString xml, QString key);
    QString Key;
};

#endif // QRZMANAGER_H
