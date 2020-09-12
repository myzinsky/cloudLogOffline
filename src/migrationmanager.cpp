#include "migrationmanager.h"

migrationManager::migrationManager()
{
    selectQuery.prepare("SELECT version FROM appData;");

    // Perform select query:
    if(!selectQuery.exec()) {
        qDebug() << "selectQuery: SQL Error" << selectQuery.lastError();
    }

    if(selectQuery.next() == false) {
        insertDatabaseVersion(QString(GIT_VERSION));
    } else {
        // Find the right migration strategy:
        QVersionNumber database = QVersionNumber::fromString(selectQuery.value(0).toString());
        QVersionNumber current  = QVersionNumber::fromString(QString(GIT_VERSION));

        if(database == current) {
            qDebug() << "No Database Migration Required.";
        } else {
            qDebug() << "Database Migration Required!";

            // Do Migration(s):
            if(database == QVersionNumber::fromString("1.0.3")) {
                from_1_0_3_to_1_0_4();
            }

            // Update Database:
            updateDatabaseVersion(QString(GIT_VERSION));
        }
    }
}

void migrationManager::from_1_0_3_to_1_0_4()
{
    bool res = addQSOColumn("SOTA_REF", "TEXT");
    res = res & addQSOColumn("MY_SOTAEF", "TEXT");
    if(res == true) {
        updateDatabaseVersion("1.0.4");
    }
}

bool migrationManager::updateDatabaseVersion(QString Version)
{
    QSqlQuery versionQuery;
    QString queryTxt = "UPDATE appData SET version = '" +
                        Version +
                        "';";
    versionQuery.prepare(queryTxt);

    if(!versionQuery.exec()) {
        qDebug() << "selectQuery: SQL Error" << selectQuery.lastError();
        return false;
    }
    return true;
}

bool migrationManager::insertDatabaseVersion(QString Version)
{
    QSqlQuery versionQuery;
    QString queryTxt = "INSERT INTO appData (version) VALUES ('" +
                        Version +
                        "');";
    versionQuery.prepare(queryTxt);

    if(!versionQuery.exec()) {
        qDebug() << "selectQuery: SQL Error" << selectQuery.lastError();
        return false;
    }
    return true;
}

bool migrationManager::addQSOColumn(QString name, QString type)
{
    QSqlQuery alterQuery;
    QString queryTxt = QString("ALTER TABLE qsos ADD COLUMN ") +
                        "\"" + name + "\" " + type + ";";
    qDebug() << queryTxt;
    alterQuery.prepare(queryTxt);

    if(!alterQuery.exec()) {
        qDebug() << "alterQuery: SQL Error" << selectQuery.lastError();
        return false;
    }
    return true;
}
