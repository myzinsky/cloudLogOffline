#ifndef CABRILLOTOOLS_H
#define CABRILLOTOOLS_H

#include <QString>
#include <QRegularExpression>
#include "logtools.h"

class cabrilloTools : public logTools
{
public:
    cabrilloTools();

    QString assemble(QString call,
                     QString mode,
                     QString freq,
                     QString date,
                     QString time,
                     QString recv,
                     QString sent,
                     QString ctss,
                     QString ctsr
            );

    QString generate();

private:
    QString convertDate(QString date);
    QString convertTime(QString time);
    QString convertFreq(QString freq);
};

#endif // CABRILLOTOOLS_H
