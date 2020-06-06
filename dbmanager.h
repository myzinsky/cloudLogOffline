#ifndef DBMANAGER_H
#define DBMANAGER_H
#include <QSqlDatabase>
#include <QDebug>
#include <QSqlQuery>
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

};

#endif // DBMANAGER_H
