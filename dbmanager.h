#ifndef DBMANAGER_H
#define DBMANAGER_H
#include <QSqlDatabase>
#include <QDebug>
#include <QSqlQuery>

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
