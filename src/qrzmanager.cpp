#include "qrzmanager.h"

qrzManager::qrzManager(QObject *parent)
{
    std::ignore = parent;

    keyManager = new QNetworkAccessManager();
    queryManager = new QNetworkAccessManager();

    QObject::connect(keyManager,
             SIGNAL(finished(QNetworkReply*)),
             this,
             SLOT(keyManagerFinished(QNetworkReply*)));

    QObject::connect(queryManager,
             SIGNAL(finished(QNetworkReply*)),
             this,
             SLOT(queryManagerFinished(QNetworkReply*)));

    receiveKey();
}

void qrzManager::receiveKey()
{
    QString qrzUser = settings.value("qrzUser").toString();
    QString qrzPass = settings.value("qrzPass").toString();

    QString qrzUrl = QString("https://xmldata.qrz.com/xml/current/?")
            +"username="
            + qrzUser
            + ";password="
            + qrzPass
            +";agent=q5.0";

    //qDebug() << qrzUrl;

    request.setUrl(QUrl(qrzUrl));
    keyManager->get(request);
}

void qrzManager::lookupCall(QString call)
{
    QString qrzUrl = QString("https://xmldata.qrz.com/xml/current/?s=")
            + Key
            + ";callsign="
            + call;

    //qDebug() << qrzUrl;

    request.setUrl(QUrl(qrzUrl));
    queryManager->get(request);
}

void qrzManager::keyManagerFinished(QNetworkReply *reply)
{
    if (reply->error()) {
        qDebug() << reply->errorString();
        return;
    }
    Key = parseXML(reply->readAll(), "Key");
    qDebug() << Key;
}

void qrzManager::queryManagerFinished(QNetworkReply *reply)
{
    qDebug() << "QRZ Query Finished";
    if (reply->error()) {
        QString error = reply->errorString();
        emit qrzFail(error);
        qDebug() << error;
        return;
    }
    QString xml = reply->readAll();
    QString error = parseXML(xml, "Error");

    if (error.isEmpty()) {
        emit qrzDone(
                    parseXML(xml, "fname"),
                    parseXML(xml, "name"),
                    parseXML(xml, "addr1"),
                    parseXML(xml, "addr2"),
                    parseXML(xml, "zip"),
                    parseXML(xml, "country"),
                    parseXML(xml, "qslmgr"),
                    parseXML(xml, "grid"),
                    parseXML(xml, "lat"),
                    parseXML(xml, "lon"),
                    parseXML(xml, "class"),
                    parseXML(xml, "cqzone"),
                    parseXML(xml, "ituzone"),
                    parseXML(xml, "born"),
                    parseXML(xml, "image")
                    );
    } else {
        qrzFail(error);
        qDebug() << error;
    }
}

QString qrzManager::parseXML(QString xml, QString key)
{
    QXmlStreamReader reader(xml);
    while(!reader.atEnd() && !reader.hasError()) {
        if(reader.readNext() == QXmlStreamReader::StartElement && reader.name() == key) {
            return reader.readElementText();
        }
    }
    return ""; // Better return nothing :)
}
