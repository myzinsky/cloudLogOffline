#ifndef CABRILLOTOOLS_H
#define CABRILLOTOOLS_H

#include <QString>
#include <QDebug>
#include <QRegularExpression>
#include <QSettings>
#include <QSqlError>
#include <QSqlQuery>

class cabrilloTools
{
public:
    cabrilloTools();

    QString assemble(QString call,
                     QString name,
                     QString mode,
                     QString freq,
                     QString date,
                     QString time,
                     QString recv,
                     QString sent,
                     QString ctry,
                     QString grid,
                     QString qqth,
                     QString comm,
                     QString ctss,
                     QString ctsr
            );

    QString generate();

private:
    QString convertDate(QString date);
    QString convertTime(QString time);
    QString convertFreq(QString freq);
    QSettings settings;
    QSqlQuery selectQuery;
};

#endif // CABRILLOTOOLS_H
