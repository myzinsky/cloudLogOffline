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

    QSqlQuery query;
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
                  "recv TEXT"
                  ");");

    if (!query.exec())
    {
        qDebug() << "Couldn't create the tables because they might already exist.";
        success = false;
    }

    return success;
}

void dbManager::openDatabase()
{
    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName("logbook.sqlite");

    if (!db.open()) {
        qDebug() << "Error: connection with database fail";
    } else {
        qDebug() << "Database: connection ok";
    }
}
