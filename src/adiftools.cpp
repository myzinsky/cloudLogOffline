#include "adiftools.h"

adifTools::adifTools()
{
    selectQuery.prepare("SELECT id,"
                        "call, "
                        "name, "
                        "ctry, "
                        "date, "
                        "time, "
                        "freq, "
                        "mode, "
                        "sent, "
                        "recv, "
                        "grid, "
                        "qqth, "
                        "comm, "
                        "ctss, "
                        "ctsr, "
                        "sync, "
                        "sota, "
                        "sots, "
                        "satn, "
                        "satm "
                        "FROM qsos");
}

void adifTools::parse(QString adif,
                      QString &call,
                      QString &name,
                      QString &mode,
                      QString &freq,
                      QString &date,
                      QString &time,
                      QString &recv,
                      QString &sent,
                      QString &ctry,
                      QString &grid)
{
    QRegularExpression re("^"
                          "<call:\\d+>(.+)"       // 1
                          "<band:\\d+>(.+)"       // 2
                          "<mode:\\d+>(.+)"       // 3
                          "<freq:\\d+>(.+)"       // 4
                          "<qso_date:\\d+>(.+)"   // 5
                          "<time_on:\\d+>(.+)"    // 6
                          "<time_off:\\d+>(.+)"   // 7
                          "<rst_rcvd:\\d+>(.+)"   // 8
                          "<rst_sent:\\d+>(.+)"   // 9
                          "<country:\\d+>(.+)"    // 10
                          "<gridsquare:\\d+>(.+)" // 11
                          "<name:\\d+>(.+)<eor>"  // 12
                          "$");
    QRegularExpressionMatch match = re.match(adif);

    if (match.hasMatch()) {
       call = match.captured( 1);
       name = match.captured(12);
       mode = match.captured( 3);
       freq = match.captured( 4);

       QString d = match.captured( 5);

       QRegularExpression re2("(\\d\\d\\d\\d)(\\d\\d)(\\d\\d)");
       QRegularExpressionMatch match2 = re2.match(d);

       date = match2.captured(3) + "." +
              match2.captured(2) + "." +
              match2.captured(1);

       QString t = match.captured( 6);

       QRegularExpression re3("(\\d\\d)(\\d\\d)(\\d\\d)");
       QRegularExpressionMatch match3 = re3.match(t);

       time = match3.captured(1) + ":" +
              match3.captured(2);

       recv = match.captured( 8);
       sent = match.captured( 9);
       ctry = match.captured(10);
       grid = match.captured(11);
    }

    qDebug() << call << name;
}

QString adifTools::assemble(QString call,
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
                            QString satn,
                            QString satm)
{
    QString band  = this->band(freq);
    QString dateN = convertDate(date);
    QString timeN = convertTime(time);
    QString freqN = convertFreq(freq);

    QString str = QString("") +
                  "<call:"     + QString::number(call.size())  + ">" + call +
                  "<band:"     + QString::number(band.size())  + ">" + band +
                  "<mode:"     + QString::number(mode.size())  + ">" + mode +
                  "<freq:"     + QString::number(freqN.size()) + ">" + freqN +
                  "<qso_date:" + QString::number(dateN.size()) + ">" + dateN +
                  "<time_on:"  + QString::number(timeN.size()) + ">" + timeN +
                  "<time_off:" + QString::number(timeN.size()) + ">" + timeN +
                  "<rst_rcvd:" + QString::number(recv.size())  + ">" + recv +
                  "<rst_sent:" + QString::number(sent.size())  + ">" + sent;

    // Contest mode:
    if(!ctss.isEmpty()) {
        bool ok;
        ctss.toInt(&ok, 10);
        if(ok == false) { // If not a number:
            str += QString("") +
                    "<stx_string:" + QString::number(ctss.size()) + ">" + ctss;
        } else { // its a number
            str += QString("") +
                    "<stx:" + QString::number(ctss.size()) + ">" + ctss;
        }
    }

    if(!ctsr.isEmpty()) {
        bool ok;
        ctsr.toInt(&ok, 10);
        if(ok == false) { // If not a number:
            str += QString("") +
                    "<srx_string:" + QString::number(ctsr.size()) + ">" + ctsr;
        } else { // its a number
            str += QString("") +
                    "<srx:" + QString::number(ctsr.size()) + ">" + ctsr;
        }
    }

    // SOTA:
    if(!sota.isEmpty()) {
        str += QString("") +
                "<sota_ref:" + QString::number(sota.size()) + ">" + sota;
    }

    if(!sots.isEmpty()) {
        str += QString("") +
                "<my_sota_ref:" + QString::number(sots.size()) + ">" + sots;
    }

    // SAT:
    if(!satn.isEmpty()) {
        str += QString("") +
                "<sat_name:" + QString::number(satn.size()) + ">" + satn;
    }

    if(!satm.isEmpty()) {
        str += QString("") +
                "<sat_mode:" + QString::number(satm.size()) + ">" + satm;
    }

    str += QString("") +
           "<country:"    + QString::number(ctry.size()) + ">" + ctry +
           "<qth:"        + QString::number(qqth.size()) + ">" + qqth +
           "<gridsquare:" + QString::number(grid.size()) + ">" + grid +
           "<name:"       + QString::number(name.size()) + ">" + name +
           "<comment:"    + QString::number(comm.size()) + ">" + comm +
           "<eor>";

    return str;
}

QString adifTools::generate()
{
    performQuery();

    QString output;

    output = QString("") +
            "<ADIF_VERS:5>3.1.0\n" +
            "<PROGRAMID:15>CloudLogOffline\n" +
            "<PROGRAMVERSION:13>Version " + QString(GIT_VERSION) + "\n"
            "<EOH>\n\n";

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
        QString sota = selectQuery.value(16).toString();
        QString sots = selectQuery.value(17).toString();
        QString satn = selectQuery.value(18).toString();
        QString satm = selectQuery.value(19).toString();

        output += assemble(call,
                           name,
                           mode,
                           freq,
                           date,
                           time,
                           recv,
                           sent,
                           ctry,
                           grid,
                           qtth,
                           comm,
                           ctss,
                           ctsr,
                           sota,
                           sots,
                           satn,
                           satm
                          ) + "\n\n";
    }
    return output;
}

QString adifTools::band(QString freq)
{
    double f = freq.toDouble();

         if(f >= 0.136  && f <= 0.137 ) return "2190m";
    else if(f >= 0.501  && f <= 0.504 ) return "560m";
    else if(f >= 1.8    && f <= 2.0   ) return "160m";
    else if(f >= 3.5    && f <= 4.0   ) return "80m";
    else if(f >= 5.102  && f <= 5.404 ) return "60m";
    else if(f >= 7.0    && f <= 7.3   ) return "40m";
    else if(f >= 10.0   && f <= 10.15 ) return "30m";
    else if(f >= 14.0   && f <= 14.35 ) return "20m";
    else if(f >= 18.068 && f <= 18.168) return "17m";
    else if(f >= 21.0   && f <= 21.45 ) return "15m";
    else if(f >= 24.890 && f <= 24.99 ) return "12m";
    else if(f >= 28.0   && f <= 29.7  ) return "10m";
    else if(f >= 50     && f <= 54    ) return "6m";
    else if(f >= 70     && f <= 71    ) return "4m";
    else if(f >= 144    && f <= 148   ) return "2m";
    else if(f >= 222    && f <= 225   ) return "1.25m";
    else if(f >= 420    && f <= 450   ) return "70cm";
    else if(f >= 902    && f <= 928   ) return "33cm";
    else if(f >= 1240   && f <= 1300  ) return "23cm";
    else if(f >= 2300   && f <= 2450  ) return "13cm";
    else if(f >= 3300   && f <= 3500  ) return "9cm";
    else if(f >= 5650   && f <= 5925  ) return "6cm";
    else if(f >= 10000  && f <= 10500 ) return "3cm";
    else if(f >= 24000  && f <= 24250 ) return "1.25cm";
    else if(f >= 47000  && f <= 47200 ) return "6mm";
    else if(f >= 75500  && f <= 81000 ) return "4mm";
    else if(f >= 119980 && f <= 120020) return "2.5mm";
    else if(f >= 142000 && f <= 149000) return "2mm";
    else if(f >= 241000 && f <= 250000) return "1mm";

    return "";
}

QString adifTools::convertDate(QString date)
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
    return year+month+day;
}

QString adifTools::convertTime(QString time)
{
    QRegularExpression re("^(\\d\\d):(\\d\\d)$");
    QRegularExpressionMatch match = re.match(time);

    QString hours = "00";
    QString minutes = "00";

    if (match.hasMatch()) {
       hours = match.captured(1);
       minutes = match.captured(2);
    }

    return hours+minutes+"00";
}

QString adifTools::convertFreq(QString freq)
{
     return QString::number(freq.toDouble(), 'f', 6);
}

