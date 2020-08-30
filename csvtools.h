#ifndef CSVTOOLS_H
#define CSVTOOLS_H

#include "logtools.h"

class csvTools : public logTools
{
public:
    csvTools();

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
    QString convertTime(QString time);
    QString convertDate(QString date);
    QString convertFreq(QString freq);

};

#endif // CSVTOOLS_H
