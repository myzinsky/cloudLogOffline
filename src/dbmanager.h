#ifndef DBMANAGER_H
#define DBMANAGER_H
#include <QSqlDatabase>
#include <QDebug>
#include <QSqlQuery>
#include <QSqlError>
#include <QStandardPaths>

class dbManager
{

public:
    dbManager();
    ~dbManager();

    bool createTables();
    void openDatabase();

private:
    QSqlDatabase db;
    QSqlQuery versionQuery;

};

#endif // DBMANAGER_H
