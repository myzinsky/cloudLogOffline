#include "cloudlogmanager.h"

cloudlogManager::cloudlogManager()
{
    manager = new QNetworkAccessManager(this);
    connect(manager,
            SIGNAL(finished(QNetworkReply*)),
            this,
            SLOT(callbackCloudLog(QNetworkReply*))
    );
}

void cloudlogManager::uploadQSO(QString url,
                                QString key,
                                QString call,
                                QString name,
                                QString mode,
                                QString freq,
                                QString date,
                                QString time,
                                QString recv,
                                QString sent,
                                QString ctry,
                                QString grid)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QByteArray data;

    QString band  = adifBand(freq);
    QString dateN = convertDate(date);
    QString timeN = convertTime(time);

    QString str = QString("") +
    "{" +
        "\"key\":\"" + key +"\"," +
        "\"type\":\"adif\"," +
        "\"string\":\"" +
            "<call:" + QString::number(call.size()) + ">"+ call +
            "<band:" + QString::number(band.size()) + ">" + band +
            "<mode:" + QString::number(mode.size()) + ">" + mode +
            "<freq:" + QString::number(freq.size()) + ">" + freq +
            "<qso_date:" + QString::number(dateN.size()) + ">" + dateN +
            "<time_on:"  + QString::number(timeN.size()) + ">" + timeN +
            "<time_off:" + QString::number(timeN.size()) + ">" + timeN +
            "<rst_rcvd:" + QString::number(recv.size()) + ">" + recv +
            "<rst_sent:" + QString::number(sent.size()) + ">" + sent +
            //"<qsl_rcvd:1>N" +
            //"<qsl_sent:1>N" +
            "<country:" + QString::number(ctry.size()) + ">" + ctry +
            "<gridsquare:" + QString::number(grid.size()) + ">"+ grid +
            //"<sat_mode:3>U/V" +
            //"<sat_name:4>AO-7" +
            //"<prop_mode:3>SAT" +
            "<name:" + QString::number(name.size()) + ">" + name +
            "<eor>\"" +
    "}";

    data = str.toUtf8();

    QUrl u = QUrl("https://"+url+"/index.php/api/qso");

    QNetworkRequest request(u);
    request.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("application/json"));
    manager->post(request, data);

    qDebug() << "Update Cloud Log: " << str;
}

void cloudlogManager::callbackCloudLog(QNetworkReply *rep)
{
    //{\"status\":\"created\", ...
    //"{\"status\":\"failed\",\"reason\":\"missing api key\"}"

    QString response = rep->readAll();
    QJsonDocument jsonResponse = QJsonDocument::fromJson(response.toUtf8());
    QJsonObject jsonObject = jsonResponse.object();

    if(jsonObject["status"] == "created") {
        QString adif = jsonObject["string"].toString();
        QString call;
        QString name;
        QString ctry;
        QString date;
        QString time;
        QString freq;
        QString mode;
        QString sent;
        QString recv;
        QString grid;

        parseAdif(adif,
                  call,
                  name,
                  mode,
                  freq,
                  date,
                  time,
                  recv,
                  sent,
                  ctry,
                  grid);

        // TODO: change sync status... start here
    }

    qDebug () << QString(jsonObject["status"].toString());
}

void cloudlogManager::uploadToCloudLog(QString url, QString key)
{
    QSqlQuery query; //   0     1     2     3     4     5     6     7     8     9     10
    query.prepare("SELECT call, "
                  "name, "
                  "ctry, "
                  "date, "
                  "time, "
                  "freq, "
                  "mode, "
                  "sent, "
                  "recv, "
                  "grid, "
                  "sync "
                  "FROM qsos WHERE sync = 0");

    if(!query.exec()) {
        qDebug() << "SQL Error";
    } else {
        while(query.next())
        {
            QString call = query.value( 0).toString();
            QString name = query.value( 1).toString();
            QString ctry = query.value( 2).toString();
            QString date = query.value( 3).toString();
            QString time = query.value( 4).toString();
            QString freq = query.value( 5).toString();
            QString mode = query.value( 6).toString();
            QString sent = query.value( 7).toString();
            QString recv = query.value( 8).toString();
            QString grid = query.value( 9).toString();
            QString sync = query.value(10).toString();

            uploadQSO(url,
                      key,
                      call,
                      name,
                      mode,
                      freq,
                      date,
                      time,
                      recv,
                      sent,
                      ctry,
                      grid);
        }
    }
}

QString convertDate(QString date)
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

QString convertTime(QString time)
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

QString adifBand(QString freq)
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

void parseAdif(QString adif,
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
       date = match.captured( 5);
       time = match.captured( 6);
       recv = match.captured( 8);
       sent = match.captured( 9);
       ctry = match.captured(10);
       grid = match.captured(11);
    }

    qDebug() << call << name;
}
