#include "cabrillotools.h"

cabrilloTools::cabrilloTools()
{
}

QString cabrilloTools::assemble(QString call,
                                QString mode,
                                QString freq,
                                QString date,
                                QString time,
                                QString recv,
                                QString sent,
                                QString ctss,
                                QString ctsr)
{
    // GOAL:::::::::::::::::::::::::::::::
    // QSO: 14000 CW 2010-10-16 1745 DJ9MH         599 B10    UR7NY         599 082    0
    // QSO: 14000 CW 2010-10-16 1749 DJ9MH         599 B10    UW5M          599 274    0
    // QSO: 14000 PH 2010-10-16 1750 DJ9MH         59  B10    R3CM          59  248    0
    // QSO: 14000 CW 2010-10-16 1751 DJ9MH         599 B10    HA8VK         599 078    0
    // QSO:  3500 CW 2010-10-16 1758 DJ9MH         599 B10    DQ750UEM      599 750UEM
    // QSO:  3500 PH 2010-10-17 1023 DJ9MH         59  B10    DB6MC         59  NM

    // remove submode
    QString modeWithoutSubmode = mode;
    if (mode.contains(" / ")) {
        QStringList modeParts = mode.split(" / ");
        if (modeParts.size() == 2) {
            modeWithoutSubmode = modeParts.at(0);
        }
    }

    QString str = QString("") +
            "QSO: " +
            convertFreq(freq) +
            " " +
            modeWithoutSubmode +
            " " +
            convertDate(date) +
            " " +
            convertTime(time) +
            " " +
            settings.value("call").toString().toUpper() +
            " " +
            sent +
            " " +
            ctss +
            " " +
            call +
            " " +
            recv +
            " " +
            ctsr +
            "\n";

    return str;
}

QString cabrilloTools::generate(
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
    performQuery();
    QString output;
    output = QString("") +
            "START-OF-LOG: 3.0\n" +
            "CREATED-BY: ClougLogOffline Version " + QString(GIT_VERSION) + " (c) 2020 by DL9MJ\n"
            "CONTEST: " + " " + "\n" +
            "CALLSIGN: " + settings.value("call").toString().toUpper() + "\n"
            "SPECIFIC: " + settings.value("contestNumber").toString().toUpper() + "\n"
            "CONTEST: " + cabrilloContest + "\n" +
            "CATEGORY-ASSISTED: " + cabrilloAssisted + "\n" +
            "CATEGORY-BAND: " + cabrilloBand + "\n" +
            "CATEGORY-MODE: " + cabrilloMode + "\n" +
            "CATEGORY-OPERATOR: " + cabrilloOperator + "\n" +
            "CATEGORY-POWER: " + cabrilloPower + "\n" +
            "CATEGORY-STATION: " + cabrilloStation + "\n" +
            "CATEGORY-TIME: " + cabrilloTime + "\n" +
            "CATEGORY-TRANSMITTER: " + cabrilloTransmitter + "\n" +
            "CATEGORY-OVERLAY: " + cabrilloOverlay + "\n" +
            "CERTIFICATE: " + cabrilloCertificate + "\n" +
            "CLAIMED-SCORE: " + cabrilloScore + "\n" +
            "CLUB: " + cabrilloClub + "\n" +
            "EMAIL: " + cabrilloEmail + "\n" +
            "GRID-LOCATOR: " + cabrilloGridLocator + "\n" +
            "LOCATIONS: " + cabrilloLocation + "\n" +
            "NAME: " + cabrilloName + "\n" +
            "ADDRESS: " + cabrilloAddress + "\n" +
            "OPERATORS: " + cabrilloOperators + "\n" +
            "SOAPBOX: " + cabrilloSoapbox + "\n" +
            "\n\n";

    while(selectQuery.next()) {
        QString id   = selectQuery.value( 0).toString();
        QString call = selectQuery.value( 1).toString();
        QString name = selectQuery.value( 2).toString();
        QString ctry = selectQuery.value( 3).toString();
        QString date = selectQuery.value( 4).toString();
        QString time = selectQuery.value( 5).toString();
        QString freq = selectQuery.value( 6).toString();
        QString mode = selectQuery.value( 7).toString();
        QString sent = selectQuery.value( 8).toString();
        QString recv = selectQuery.value( 9).toString();
        QString grid = selectQuery.value(10).toString();
        QString qtth = selectQuery.value(11).toString();
        QString comm = selectQuery.value(12).toString();
        QString ctss = selectQuery.value(13).toString();
        QString ctsr = selectQuery.value(14).toString();
        QString sync = selectQuery.value(15).toString();

        output += assemble(call,
                           mode,
                           freq,
                           date,
                           time,
                           recv,
                           sent,
                           ctss,
                           ctsr
                          );
    }

    output += "END-OF-LOG:\n";

    return output;
}

QString cabrilloTools::convertTime(QString time)
{
    QRegularExpression re("^(\\d\\d):(\\d\\d)$");
    QRegularExpressionMatch match = re.match(time);

    QString hours = "00";
    QString minutes = "00";

    if (match.hasMatch()) {
       hours = match.captured(1);
       minutes = match.captured(2);
    }

    return hours+minutes;
}

QString cabrilloTools::convertDate(QString date)
{
    QRegularExpression re("^(\\d\\d)\\.(\\d\\d)\\.(\\d\\d\\d\\d)$");
    QRegularExpressionMatch match = re.match(date);

    QString day = "00";
    QString month = "00";
    QString year = "0000";

    if (match.hasMatch()) {
       day = match.captured(1);
       month = match.captured(2);
       year = match.captured(3);
    }
    return year+"-"+month+"-"+day;
}

QString cabrilloTools::convertFreq(QString freq)
{
    return QString::number(int(freq.toDouble()*1000), 10);
}
