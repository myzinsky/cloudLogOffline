#include "cloudlogmanager.h"

cloudlogManager::cloudlogManager(qsoModel *model) : model(model)
{
    manager = new QNetworkAccessManager(this);
    connect(manager,
            SIGNAL(finished(QNetworkReply*)),
            this,
            SLOT(callbackCloudLog(QNetworkReply*))
    );

    selectQuery.prepare("SELECT call, "
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
}

void cloudlogManager::uploadQSO(QString url,
                                QString ssl,
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

    QUrl u = QUrl(ssl+"://"+url+"/index.php/api/qso");

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

        QSqlQuery query;
        QString qS =  "UPDATE qsos SET sync = 1 WHERE "
                      "call = \""+call+"\" AND "
                      "name = \""+name+"\" AND "
                      "mode = \""+mode+"\" AND "
                      "freq = \""+freq+"\" AND "
                      "date = \""+date+"\" AND "
                      "time = \""+time+"\" AND "
                      "recv = \""+recv+"\" AND "
                      "sent = \""+sent+"\" AND "
                      "ctry = \""+ctry+"\" AND "
                      "grid = \""+grid+"\";";

        query.prepare(qS);

        std::cout << "DB: " << qS.toStdString() << std::endl;

        if(!query.exec()) {
            qDebug() << "SQL Error";
        } else {
            qDebug() << "DB: Successfull";
        }

        done++;

        if(done < number) {
            uploadNext();
        } else {
            model->select(); // Done! Redraw the model!
        }

        emit uploadSucessfull(((double)done)/((double)number));

    } else {
        // TODO: show message box
    }

    // TODO: what if callback is not happening or request fails?
}

void cloudlogManager::uploadToCloudLog(QString ssl, QString url, QString key)
{
    this->url = url;
    this->key = key;
    this->ssl = ssl;

    // Estimate how many uploads:
    QSqlQuery query;
    query.prepare("SELECT COUNT(*) FROM qsos WHERE sync = 0");

    if(!query.exec()) {
        qDebug() << "SQL Error:" << query.lastError().text();
    }

    query.next();
    number = query.value(0).toInt();
    done = 0;

    // Perform select query:
    if(!selectQuery.exec()) {
        qDebug() << "selectQuery: SQL Error" << selectQuery.lastError();
    } else {
        qDebug() << "selectQuery: exec ok";
    }

    if(number > 0) {
        uploadNext(); // Start downloading
    }
}

void cloudlogManager::uploadNext()
{
    qDebug() << "Upload" << (done+1) << "/" << number;
    selectQuery.next();

    QString call = selectQuery.value( 0).toString();
    QString name = selectQuery.value( 1).toString();
    QString ctry = selectQuery.value( 2).toString();
    QString date = selectQuery.value( 3).toString();
    QString time = selectQuery.value( 4).toString();
    QString freq = selectQuery.value( 5).toString();
    QString mode = selectQuery.value( 6).toString();
    QString sent = selectQuery.value( 7).toString();
    QString recv = selectQuery.value( 8).toString();
    QString grid = selectQuery.value( 9).toString();
    QString sync = selectQuery.value(10).toString();

    uploadQSO(url,
              ssl,
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

void cloudlogManager::deleteUploadedQsos()
{
    QSqlQuery query;
    query.prepare("DELETE FROM qsos WHERE sync = 1");

    if(!query.exec()) {
        qDebug() << "SQL Error:" << query.lastError().text();
    }
}

QString cloudlogManager::convertDate(QString date)
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

QString cloudlogManager::convertTime(QString time)
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

QString cloudlogManager::adifBand(QString freq)
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

void cloudlogManager::parseAdif(QString adif,
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
