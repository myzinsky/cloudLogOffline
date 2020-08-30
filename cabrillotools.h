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

    QString generate(
            QString cabrilloContest,
            QString cabrilloAssisted,
            QString cabrilloBand,
            QString cabrilloMode,
            QString cabrilloOperator,
            QString cabrilloPower,
            QString cabrilloStation,
            QString cabrilloTime,
            QString cabrilloTransmitter,
            QString cabrilloOverlay,
            QString cabrilloCertificate,
            QString cabrilloScore,
            QString cabrilloClub,
            QString cabrilloEmail,
            QString cabrilloGridLocator,
            QString cabrilloLocation,
            QString cabrilloName,
            QString cabrilloAddress,
            QString cabrilloOperators,
            QString cabrilloSoapbox
        );

private:
    QString convertDate(QString date);
    QString convertTime(QString time);
    QString convertFreq(QString freq);
};

#endif // CABRILLOTOOLS_H
