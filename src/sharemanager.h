#ifndef SHAREMANAGER_H
#define SHAREMANAGER_H

#include <QQuickItem>
#include <QGuiApplication>
#include <QClipboard>

#include "adiftools.h"
#include "cabrillotools.h"
#include "csvtools.h"

class shareManager : public QQuickItem
{
    Q_OBJECT
public:
    explicit shareManager(QQuickItem *parent = 0);
    Q_INVOKABLE void shareADIF();
    Q_INVOKABLE void shareCabrillo(
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
    Q_INVOKABLE void shareCSV();
private:
    void share(const QString &text);

    adifTools adif;
    cabrilloTools cabrillo;
    csvTools csv;
};

#endif //SHAREMANAGER_H
