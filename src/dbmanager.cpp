#include "dbmanager.h"

dbManager::dbManager()
{
    openDatabase();
}

dbManager::~dbManager()
{
   if(db.open()) {
       db.close();
   }
}

bool dbManager::createTables()
{
    bool success = false;
    bool success2 = false;

    QSqlQuery query;

    // 1.0.3
    query.prepare("CREATE TABLE qsos("
                  "id INTEGER PRIMARY KEY,"
                  "call TEXT,"
                  "name TEXT,"
                  "ctry TEXT,"
                  "date TEXT,"
                  "time TEXT,"
                  "freq TEXT,"
                  "mode TEXT,"
                  "sent TEXT,"
                  "recv TEXT,"
                  "grid TEXT,"
                  "qqth TEXT,"
                  "comm TEXT,"
                  "ctss TEXT,"
                  "ctsr TEXT,"
                  "sync INTEGER DEFAULT 0"
                  ");");

    success = query.exec();

    query.prepare("CREATE TABLE appData("
                  "version TEXT"
                  ");");

    success2 = query.exec();

    if (success == false || success2 == false) {
        qDebug() << "Couldn't create the tables because they might already exist.";
    }

    return success && success2;
}

void dbManager::openDatabase()
{
    QString dbName = "logbook.sqlite";
    QString dbLocation;

    if (QSysInfo::productType() == "android") {
        dbLocation = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
    } else { // ios, macos, ... windows and debian not yet tested
        dbLocation = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    }

    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(dbLocation + "/" +dbName);
    db.database(dbLocation + "/" +dbName);
    db.databaseName();

    if (!db.open()) {
        qDebug() << "Error: connection with database failed: " << dbLocation << "/" << dbName;
    } else {
        qDebug() << "Database: connection ok";
    }
}
