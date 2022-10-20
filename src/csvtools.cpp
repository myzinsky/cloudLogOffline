#include "csvtools.h"

csvTools::csvTools()
{

}

QString csvTools::assemble(QString call,
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
                           QString loca
                           )
{
    return QString("") +
           date + ", " +
           time + ", " +
           call + ", " +
           name + ", " +
           freq + ", " +
           mode + ", " +
           recv + ", " +
           sent + ", " +
           ctsr + ", " +
           ctss + ", " +
           ctry + ", " +
           grid + ", " +
           loca + ", " +
           qqth + ", " +
           comm;
}

QString csvTools::generate()
{
    performQuery();

    QString output;
    output +=  "Date, "
               "Time, "
               "Call, "
               "Name, "
               "Frequency, "
               "Mode, "
               "Received, "
               "Sent, "
               "Contest Received, "
               "Contest Sent, "
               "Country, "
               "Grid, "
               "MyGrid, "
               "QTH, "
               "Comment\n";

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
        QString loca = selectQuery.value(16).toString();

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
                           loca
                          ) + "\n";
    }
    return output;
}

QString csvTools::convertTime(QString time)
{
    return time;
}

QString csvTools::convertDate(QString date)
{
    return date;
}

QString csvTools::convertFreq(QString freq)
{
    return freq;
}
