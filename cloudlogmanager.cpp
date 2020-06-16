#include "cloudlogmanager.h"

cloudlogManager::cloudlogManager()
{
    manager = new QNetworkAccessManager(this);
    connect(manager,
            SIGNAL(finished(QNetworkReply*)),
            this,
            SLOT(callbackCloudLog(QNetworkReply*))
    );

    //uploadToCloudLog();
}

void cloudlogManager::uploadToCloudLog(QString url,
                                       QString key)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QByteArray data;

    QString str = QString("") +
    "{" +
        "\"key\":\""+key+"\"," +
        "\"type\":\"adif\"," +
        "\"string\":\"" +
            "<call:5>N9EAT" +
            "<band:4>70cm" +
            "<mode:3>SSB" +
            "<freq:10>432.166976" +
            "<qso_date:8>20200616" +
            "<time_on:6>170600" +
            "<time_off:6>170600" +
            "<rst_rcvd:2>59" +
            "<rst_sent:2>55" +
            "<qsl_rcvd:1>N" +
            "<qsl_sent:1>N" +
            "<country:24>United States Of America" +
            "<gridsquare:4>EN42" +
            "<sat_mode:3>U/V" +
            "<sat_name:4>AO-7" +
            "<prop_mode:3>SAT" +
            "<name:5>Marty" +
            "<eor>\"" +
    "}";

    data = str.toUtf8();

    QUrl u = QUrl("https://"+url+"/index.php/api/qso");

    QNetworkRequest request(u);
    request.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("application/json"));
    manager->post(request, data);

    qDebug() << "Update Cloud Log: " << data;
}


void cloudlogManager::callbackCloudLog(QNetworkReply *rep)
{
    qDebug () << QString(rep->readAll());
}
