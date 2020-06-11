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
    void receiveKey();

public slots:
    void lookupCall(QString call);
    void keyManagerFinished(QNetworkReply *reply);
    void queryManagerFinished(QNetworkReply *reply);

signals:
    void qrzDone(const QString &name,
                 const QString &ctry);

private:
    QSettings settings;
    QNetworkAccessManager *keyManager;
    QNetworkAccessManager *queryManager;
    QNetworkRequest request;

    QString parseXML(QString xml, QString key);
    QString Key;
};

#endif // QRZMANAGER_H
