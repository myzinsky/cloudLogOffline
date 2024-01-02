#include "sharemanager.h"

shareManager::shareManager(QQuickItem *parent) : QQuickItem(parent)
{
}

void shareManager::share(const QString &text)
{
    QClipboard *clipboard = QGuiApplication::clipboard();
    clipboard->setText(text);
}

void shareManager::shareADIF()
{
    share(adif.generate());
}

void shareManager::shareCabrillo(
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
    )
{
    share(cabrillo.generate(
              cabrilloContest,
              cabrilloAssisted,
              cabrilloBand,
              cabrilloMode,
              cabrilloOperator,
              cabrilloPower,
              cabrilloStation,
              cabrilloTime,
              cabrilloTransmitter,
              cabrilloOverlay,
              cabrilloCertificate,
              cabrilloScore,
              cabrilloClub,
              cabrilloEmail,
              cabrilloGridLocator,
              cabrilloLocation,
              cabrilloName,
              cabrilloAddress,
              cabrilloOperators,
              cabrilloSoapbox
              ));
}

void shareManager::shareCSV()
{
    share(csv.generate());
}
