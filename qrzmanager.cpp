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

    qDebug() << qrzUrl;

    request.setUrl(QUrl(qrzUrl));
    keyManager->get(request);
}

void qrzManager::lookupCall(QString call)
{
    QString qrzUrl = QString("https://xmldata.qrz.com/xml/current/?s=")
                     + Key
                     + ";callsign="
                     + call;

    qDebug() << qrzUrl;

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
    if (reply->error()) {
        qDebug() << reply->errorString();
        return;
    }
    QString xml = reply->readAll();

    QString name = parseXML(xml, "fname");
    QString ctry = parseXML(xml, "country");
    emit qrzDone(name, ctry);
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
