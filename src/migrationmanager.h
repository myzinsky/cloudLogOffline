#ifndef MIGRATIONMANAGER_H
#define MIGRATIONMANAGER_H

#include <QSettings>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QVersionNumber>

class migrationManager : public QObject
{
    Q_OBJECT

public:
    migrationManager();

public slots:
    QString getDatabaseVersion();

private:
    bool updateDatabaseVersion(QString Version);
    bool insertDatabaseVersion(QString Version);
    bool addQSOColumn(QString name, QString type);

    // Migration Methods:
    void from_1_0_3_to_1_0_4();
    void from_1_0_4_to_1_0_5();
    void from_1_0_9_to_1_1_0();

    // Bugfixes:
    void fix_1_0_5();
};

#endif // MIGRATIONMANAGER_H
