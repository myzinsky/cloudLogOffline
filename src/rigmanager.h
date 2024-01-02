#ifndef RIGMANAGER_H
#define RIGMANAGER_H

#include <QNetworkAccessManager>
#include <QXmlStreamReader>
#include <QNetworkReply>
#include <QSettings>

class rigManager : public QObject
{
    Q_OBJECT

public:
    rigManager();
    ~rigManager();

private slots:
    void callbackFrequency(QNetworkReply *rep);
    void callbackMode(QNetworkReply *rep);

public slots:
    void getFrequency(QString hostname, QString port);
    void getMode(QString hostname, QString port);

private:
    void getFromFLRig(QString hostname,
                      QString port,
                      QString command,
                      QNetworkAccessManager *manager);
    QString parseXML(QString xml);

    QNetworkAccessManager *frequencyManager;
    QNetworkAccessManager *modeManager;
    QString frequency;
    QString mode;

signals:
    void freqDone(const QString &freq);
    void modeDone(const QString &mode);
};

#endif // RIGMANAGER_H
