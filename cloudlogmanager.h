#ifndef CLOUDLOGMANAGER_H
#define CLOUDLOGMANAGER_H

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QSqlQuery>
#include <iostream>
#include <QJsonDocument>
#include <QJsonObject>
#include <QRegularExpression>
#include <QSqlError>

#include "qsomodel.h"

class cloudlogManager : public QObject
{
    Q_OBJECT

public:
    cloudlogManager(qsoModel *model);

private slots:
    void callbackCloudLog(QNetworkReply *rep);

public slots:
    void uploadToCloudLog(QString url, QString key);
    void deleteUploadedQsos();

signals:
    void uploadSucessfull(double progress);

private:
    QNetworkAccessManager *manager;
    QSqlQuery selectQuery;
    QString url;
    QString key;
    qsoModel *model;
    int number;
    int done;

    void uploadQSO(QString url,
               QString key,
               QString call,
               QString name,
               QString mode,
               QString freq,
               QString date,
               QString time,
               QString recv,
               QString sent,
               QString ctry,
               QString grid);

    void uploadNext();

    QString convertDate(QString date);
    QString convertTime(QString time);

    QString adifBand(QString freq);

    void parseAdif(QString adif,
               QString &call,
               QString &name,
               QString &mode,
               QString &freq,
               QString &date,
               QString &time,
               QString &recv,
               QString &sent,
               QString &ctry,
               QString &grid);
};
#endif // CLOUDLOGMANAGER_H
