#ifndef CLOUDLOGMANAGER_H
#define CLOUDLOGMANAGER_H

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QSqlQuery>
#include <iostream>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDomDocument>
#include <QRegularExpression>
#include <QSqlError>

#include "qsomodel.h"
#include "adiftools.h"

class cloudlogManager : public QObject
{
    Q_OBJECT

public:
    cloudlogManager(qsoModel *model);

private slots:
    void callbackCloudLog(QNetworkReply *rep);

public slots:
    void uploadToCloudLog(QString ssl, QString url, QString key, QString station_id);
    void resetMarkedQSOs();
    void deleteUploadedQsos();
    void deleteQsos();
    void testApiKey(QString ssl, QString url, QString key);

signals:
    void uploadSucessfull(double progress);
    void uploadFailed(const QString &error);
    void apiKeyOk();
    void apiKeyRo();
    void apiKeyInvalid();

private:
    adifTools adif;
    QNetworkAccessManager *manager;
    QSqlQuery selectQuery;
    QString url;
    QString key;
    QString station_id;
    QString ssl;
    qsoModel *model;
    int number;
    int done;
    QString currentIdInUpload;

    void uploadQSO(QString url,
                   QString ssl,
                   QString key,
                   QString station_id,
                   QString call,
                   QString name,
                   QString mode,
                   QString freq,
                   QString date,
                   QString time,
                   QString recv,
                   QString sent,
                   QString ctry,
                   QString grid,
                   QString qqth,
                   QString comm,
                   QString ctss,
                   QString ctsr,
                   QString sota,
                   QString sots,
                   QString wwff,
                   QString wwfs,
                   QString satn,
                   QString satm,
                   QString propmode,
                   QString rxfreq,
                   QString loca
               );

    void uploadNext();
};
#endif // CLOUDLOGMANAGER_H
