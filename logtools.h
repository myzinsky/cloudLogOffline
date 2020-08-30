#ifndef LOGTOOLS_H
#define LOGTOOLS_H

#include <QSettings>
#include <QSqlError>
#include <QSqlQuery>
#include <QDebug>

class logTools
{
public:
    logTools();

    virtual QString convertTime(QString time) = 0;
    virtual QString convertDate(QString date) = 0;
    virtual QString convertFreq(QString freq) = 0;

protected:
    QSettings settings;
    QSqlQuery selectQuery;
    void performQuery();
};

#endif // LOGTOOLS_H
