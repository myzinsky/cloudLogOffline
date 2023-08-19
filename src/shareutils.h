#ifndef SHAREUTILS_H
#define SHAREUTILS_H

#include <QQuickItem>
#include <QApplication>
#include <QClipboard>
//#include <QMessageBox>

#include "adiftools.h"
#include "cabrillotools.h"
#include "csvtools.h"

class shareUtils : public QQuickItem
{
    Q_OBJECT
public:
    explicit shareUtils(QQuickItem *parent = 0);
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

#endif //SHAREUTILS_H
