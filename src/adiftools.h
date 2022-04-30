#ifndef ADIFTOOLS_H
#define ADIFTOOLS_H

#include <QString>
#include <QDebug>
#include <QRegularExpression>
#include <QSqlError>
#include <QSqlQuery>
#include "logtools.h"

class adifTools : public logTools
{
public:
    adifTools();

    void parse(QString adif, // For future use...
               QString &call,
               QString &name,
               QString &mode,
               QString &freq,
               QString &date,
               QString &time,
               QString &recv,
               QString &sent,
               QString &ctry,
               QString &grid);

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
                     QString ctsr,
                     QString sota,
                     QString sots,
                     QString wwff,
                     QString wwfs,
                     QString satn,
                     QString satm
            );

    QString generate();

private:
    QString band(QString freq);
    QString convertDate(QString date);
    QString convertTime(QString time);
    QString convertFreq(QString freq);
};

#endif // ADIFTOOLS_H
