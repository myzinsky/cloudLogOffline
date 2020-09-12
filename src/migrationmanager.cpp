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

            // EXAMPLE:
            //if(database == QVersionNumber::fromString("1.0.3")) {
            //	  from_1_0_3_to_1_0_4();
            //    from_1_0_4_to_1_0_5();
            //}
            //else if(database == QVersionNumber::fromString("1.0.4")) {
            //    from_1_0_4_to_1_0_5();
            //}
        }
    }
}

void migrationManager::from_1_0_3_to_1_0_4()
{

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
