#include "cloudlogmanager.h"

cloudlogManager::cloudlogManager(qsoModel *model) : model(model)
{
    manager = new QNetworkAccessManager(this);
    connect(manager,
            SIGNAL(finished(QNetworkReply*)),
            this,
            SLOT(callbackCloudLog(QNetworkReply*))
    );

    selectQuery.prepare("SELECT id,"
                        "call, "
                        "name, "
                        "ctry, "
                        "date, "
                        "time, "
                        "freq, "
                        "mode, "
                        "sent, "
                        "recv, "
                        "grid, "
                        "qqth, "
                        "comm, "
                        "ctss, "
                        "ctsr, "
                        "sync, "
                        "sota, "
                        "sots, "
                        "wwff, "
                        "wwfs, "
                        "pota, "
                        "pots, "
                        "satn, "
                        "satm, "
                        "propmode, "
                        "rxfreq, "
                        "loca "
                        "FROM qsos WHERE sync = 0");
}

void cloudlogManager::uploadQSO(QString url,
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
                                QString pota,
                                QString pots,
                                QString satn,
                                QString satm,
                                QString propmode,
                                QString rxfreq,
                                QString loca
                                )
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QByteArray data;

    name.replace("\"",""); // Remove " from names

    QString str = QString("") +
    "{" +
        "\"key\":\"" + key +"\"," +
        "\"station_profile_id\":\"" + station_id +"\"," +
        "\"type\":\"adif\"," +
        "\"string\":\"" +
        adif.assemble(call,
                      name,
                      mode,
                      freq,
                      date,
                      time,
                      recv,
                      sent,
                      ctry,
                      grid,
                      qqth,
                      comm,
                      ctss,
                      ctsr,
                      sota,
                      sots,
                      wwff,
                      wwfs,
                      pota,
                      pots,
                      satn,
                      satm,
                      propmode,
                      rxfreq,
                      loca
                      ) +
        "\"" +
    "}";

    data = str.toUtf8();

    QUrl u = QUrl(ssl+"://"+url+"/index.php/api/qso");

    QNetworkRequest request(u);
    request.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("application/json"));
    request.setRawHeader ("User-Agent", "CloudLogOffline v"+QByteArray(PROJECT_VERSION));
    manager->post(request, data);

    qDebug() << "Update Cloud Log: " << str;
}

void cloudlogManager::callbackCloudLog(QNetworkReply *rep)
{
    QString contentType = rep->header(QNetworkRequest::ContentTypeHeader).toString();
    QString response = rep->readAll();

    if (contentType.contains("application/json")) {

        //{\"status\":\"created\", ...
        //"{\"status\":\"failed\",\"reason\":\"missing api key\"}"

        QJsonDocument jsonResponse = QJsonDocument::fromJson(response.toUtf8());
        QJsonObject jsonObject = jsonResponse.object();

        if(jsonObject["status"] == "created") {
            QString adifStr = jsonObject["string"].toString();

            qDebug() << "Callback: " << adifStr;

            QSqlQuery query;

            QString qS = "UPDATE qsos SET sync = 1 WHERE id = "
                    + currentIdInUpload + ";";

            query.prepare(qS);

            std::cout << "DB: " << qS.toStdString() << std::endl;

            if(!query.exec()) {
                qDebug() << "SQL Error:" << query.lastError().text();
            } else {
                qDebug() << "DB: Successfull";
            }

            done++;

            if(done < number) {
                uploadNext();
            } else {
                model->select(); // Done! Redraw the model!
            }

            emit uploadSucessfull(((double)done)/((double)number));
        } else {
            emit uploadFailed("Upload Error: " + jsonObject["reason"].toString());
        }
    }

    if (contentType.contains("text/xml")) {
        QDomDocument xmlDoc;
        xmlDoc.setContent(response.toUtf8());
        QDomElement auth = xmlDoc.namedItem("auth").toElement();
        if (auth.isNull()) {
            emit apiKeyInvalid();
        } else {
            QDomElement status = auth.namedItem("status").toElement();
            if (status.isNull()) {
                QDomElement message = auth.namedItem("message").toElement();
                qDebug() << "MESSAGE: " << message.text();
                emit apiKeyInvalid();
            }
            else if (status.text() == "Valid") {
                QDomElement rights = auth.namedItem("rights").toElement();
                if (rights.text() == "rw") {
                    emit apiKeyOk();
                } else if (rights.text() == "r") {
                    emit apiKeyRo();
                }
            }
        }
    }

    // TODO: what if callback is not happening or request fails?
}

void cloudlogManager::uploadToCloudLog(QString ssl, QString url, QString key, QString station_id)
{
    this->url = url;
    this->key = key;
    this->station_id = station_id;
    this->ssl = ssl;

    // Estimate how many uploads:
    QSqlQuery query;
    query.prepare("SELECT COUNT(*) FROM qsos WHERE sync = 0");

    if(!query.exec()) {
        qDebug() << "SQL Error:" << query.lastError().text();
    }

    query.next();
    number = query.value(0).toInt();
    done = 0;

    // Perform select query:
    if(!selectQuery.exec()) {
        qDebug() << "selectQuery: SQL Error" << selectQuery.lastError();
    } else {
        qDebug() << "selectQuery: exec ok";
    }

    if(number > 0) {
        uploadNext(); // Start downloading
    }
}

void cloudlogManager::resetMarkedQSOs()
{
    QSqlQuery query;
    query.prepare("UPDATE qsos SET sync=0;");

    if(!query.exec()) {
        qDebug() << "SQL Error:" << query.lastError().text();
    }
}

void cloudlogManager::uploadNext()
{
    qDebug() << "Upload" << (done+1) << "/" << number;
    selectQuery.next();

    QString id       = selectQuery.value( 0).toString();
    QString call     = selectQuery.value( 1).toString();
    QString name     = selectQuery.value( 2).toString();
    QString ctry     = selectQuery.value( 3).toString();
    QString date     = selectQuery.value( 4).toString();
    QString time     = selectQuery.value( 5).toString();
    QString freq     = selectQuery.value( 6).toString();
    QString mode     = selectQuery.value( 7).toString();
    QString sent     = selectQuery.value( 8).toString();
    QString recv     = selectQuery.value( 9).toString();
    QString grid     = selectQuery.value(10).toString();
    QString qtth     = selectQuery.value(11).toString();
    QString comm     = selectQuery.value(12).toString();
    QString ctss     = selectQuery.value(13).toString();
    QString ctsr     = selectQuery.value(14).toString();
    QString sync     = selectQuery.value(15).toString();
    QString sota     = selectQuery.value(16).toString();
    QString sots     = selectQuery.value(17).toString();
    QString wwff     = selectQuery.value(18).toString();
    QString wwfs     = selectQuery.value(19).toString();
    QString pota     = selectQuery.value(20).toString();
    QString pots     = selectQuery.value(21).toString();
    QString satn     = selectQuery.value(22).toString();
    QString satm     = selectQuery.value(23).toString();
    QString propmode = selectQuery.value(24).toString();
    QString rxfreq   = selectQuery.value(25).toString();
    QString loca     = selectQuery.value(26).toString();

    currentIdInUpload = id;

    uploadQSO(url,
              ssl,
              key,
              station_id,
              call,
              name,
              mode,
              freq,
              date,
              time,
              recv,
              sent,
              ctry,
              grid,
              qtth,
              comm,
              ctss,
              ctsr,
              sota,
              sots,
              wwff,
              wwfs,
              pota,
              pots,
              satn,
              satm,
              propmode,
              rxfreq,
              loca
              );
}

void cloudlogManager::deleteUploadedQsos()
{
    QSqlQuery query;
    query.prepare("DELETE FROM qsos WHERE sync = 1");

    if(!query.exec()) {
        qDebug() << "SQL Error:" << query.lastError().text();
    }
}

void cloudlogManager::deleteQsos()
{
    QSqlQuery query;
    query.prepare("DELETE FROM qsos");

    if(!query.exec()) {
        qDebug() << "SQL Error:" << query.lastError().text();
    }
}

void cloudlogManager::testApiKey(QString ssl, QString url, QString key)
{
    QUrl u = QUrl(ssl+"://"+url+"/index.php/api/auth/"+key);
    QNetworkRequest request(u);
    request.setRawHeader ("User-Agent", "CloudLogOffline v"+QByteArray(PROJECT_VERSION));
    request.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("application/json"));
    manager->get(request);
    //return true;
}
