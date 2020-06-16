#ifndef CLOUDLOGMANAGER_H
#define CLOUDLOGMANAGER_H

#include <QNetworkAccessManager>
#include <QNetworkReply>

class cloudlogManager : public QObject
{
    Q_OBJECT

public:
    cloudlogManager();

private slots:
    void callbackCloudLog(QNetworkReply *rep);

public slots:
    void uploadToCloudLog(QString url, QString key);

private:
    QNetworkAccessManager *manager;
};

#endif // CLOUDLOGMANAGER_H
