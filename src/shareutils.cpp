#include "shareutils.h"

shareUtils::shareUtils(QQuickItem *parent) : QQuickItem(parent)
{
}

void shareUtils::share(const QString &text)
{
    QClipboard *clipboard = QApplication::clipboard();
    clipboard->setText(text);
    //
    //QMessageBox msgBox;
    //msgBox.setText("Copied to Clipboard");
    //msgBox.exec();
}

void shareUtils::shareADIF()
{
    share(adif.generate());
}

void shareUtils::shareCabrillo(
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

void shareUtils::shareCSV()
{
    share(csv.generate());
}
