#include "rigmanager.h"

rigManager::rigManager()
{
    // Setup HTTP Request Managers:
    frequencyManager = new QNetworkAccessManager(this);
    connect(frequencyManager,
            SIGNAL(finished(QNetworkReply*)),
            this,
            SLOT(callbackFrequency(QNetworkReply*))
    );

    modeManager = new QNetworkAccessManager(this);
    connect(modeManager,
            SIGNAL(finished(QNetworkReply*)),
            this,
            SLOT(callbackMode(QNetworkReply*))
    );
}

rigManager::~rigManager()
{
}

QString rigManager::parseXML(QString xml)
{
    QXmlStreamReader reader(xml);
    while(!reader.atEnd() && !reader.hasError()) {
        if(reader.readNext() == QXmlStreamReader::StartElement && reader.name().compare("value")) {
            return reader.readElementText();
        }
    }

    return QString("ERROR");
}

void rigManager::callbackFrequency(QNetworkReply *rep)
{
    QString f = parseXML(QString(rep->readAll()));
    if(f != frequency) { // Update UI and Cloudlog
        frequency = QString::number(f.toDouble()/1000.0/1000.0, 'f', 6);
        emit freqDone(frequency);
    }
}

void rigManager::callbackMode(QNetworkReply *rep)
{
    QString m = parseXML(QString(rep->readAll()));
    if(m != mode) { // Update UI and Cloudlog
        mode = m;
        emit modeDone(mode);
    }
}

void rigManager::getFromFLRig(QString hostname,
                              QString port,
                              QString command,
                              QNetworkAccessManager *manager)
{
    QByteArray data;
    data.append("<?xml version=\"1.0\"?><methodCall><methodName>"
                + command.toUtf8()
                + "</methodName><params></params></methodCall>");

    QUrl url = QUrl("http://"+hostname);
    url.setPort(port.toInt());

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("application/x-www-form-urlencoded"));
    manager->post(request, data);
}

void rigManager::getFrequency(QString hostname, QString port)
{
    getFromFLRig(hostname, port, "rig.get_vfo", frequencyManager);
}

void rigManager::getMode(QString hostname, QString port)
{
    getFromFLRig(hostname, port, "rig.get_mode", modeManager);
}
