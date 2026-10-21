// The DxQSO two-way sync, end to end against a fake DxQSO API on localhost.

#include <QtTest>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSettings>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QTcpServer>
#include <QTcpSocket>

#include "dxqsomanager.h"
#include "qsomodel.h"

/* Just enough of the DxQSO API: /upload, /logbook/download, /logbook/delete. */
class FakeDxqso : public QObject
{
    Q_OBJECT
public:
    QTcpServer server;
    int nextId = 1;
    int status = 200;                     // what every call answers with
    QByteArray errorBody;
    QList<QJsonObject> uploads;           // every QSO uploaded, in order
    QStringList deletes;                  // every qso_id deleted
    QList<QJsonObject> downloadQueue;     // what the next download returns
    QStringList downloadQueries;
    QList<QByteArray> nextTokens;         // X-Next-Token sent with each download
    QString noVerdictFor;                 // a call the upload answers nothing for
    bool failDeletes = false;             // /logbook/delete answers 500
    QHash<QString, QString> naturalKeys;  // call|date|time -> qso_id, as DxQSO dedupes

    FakeDxqso() {
        server.listen(QHostAddress::LocalHost);
        connect(&server, &QTcpServer::newConnection, this, [this]() {
            QTcpSocket *s = server.nextPendingConnection();
            connect(s, &QTcpSocket::readyRead, this, [this, s]() { handle(s); });
        });
    }
    QString url() const { return QString("http://127.0.0.1:%1").arg(server.serverPort()); }

private:
    QHash<QTcpSocket *, QByteArray> buffers;

    void handle(QTcpSocket *s) {
        QByteArray &buf = buffers[s];
        buf += s->readAll();
        int end = buf.indexOf("\r\n\r\n");
        if (end < 0) return;
        QByteArray head = buf.left(end);
        int length = 0;
        QByteArray next;
        for (const QByteArray &line : head.split('\n')) {
            QByteArray l = line.trimmed();
            if (l.toLower().startsWith("content-length:")) length = l.mid(15).trimmed().toInt();
            if (l.toLower().startsWith("x-next-token:")) next = l.mid(13).trimmed();
        }
        if (buf.size() < end + 4 + length) return;
        QByteArray body = buf.mid(end + 4, length);
        buffers.remove(s);
        QList<QByteArray> requestLine = head.split('\n').first().trimmed().split(' ');
        QUrl url(QString::fromUtf8(requestLine.value(1)));
        QJsonObject in = QJsonDocument::fromJson(body).object();

        QByteArray out;
        QByteArray extra;
        if (status != 200 || (failDeletes && url.path() == "/logbook/delete")) {
            out = errorBody;
        } else if (url.path() == "/upload") {
            QJsonArray results;
            for (const QJsonValue &v : in["qsos"].toArray()) {
                QJsonObject q = v.toObject();
                uploads << q;
                if (q["call"].toString() == noVerdictFor) continue;
                // Like DxQSO: no qso_id -> matched on the natural key, or a new record.
                QString key = q["call"].toString() + "|" + q["qso_date"].toString() + "|" + q["time_on"].toString().left(4);
                QString id = q.contains("qso_id") ? q["qso_id"].toString() : naturalKeys.value(key);
                QString action = id.isEmpty() ? "inserted" : "updated";
                if (id.isEmpty()) id = QString("id-%1").arg(nextId++);
                naturalKeys.insert(key, id);
                if (q["call"].toString() == "REJECT") action = "rejected";
                results.append(QJsonObject{{"action", action}, {"qso_id", id}, {"call", q["call"]},
                    {"qso_date", q["qso_date"]}, {"time_on", q["time_on"]}, {"reason", "test"}});
            }
            out = QJsonDocument(QJsonObject{{"results", results}}).toJson();
        } else if (url.path() == "/logbook/download") {
            downloadQueries << url.query();
            nextTokens << next;
            QJsonArray qsos;
            // Two pages when there is more than one record: proves the cursor is followed.
            if (next.isEmpty() && downloadQueue.size() > 1) {
                qsos.append(downloadQueue.takeFirst());
                extra = "X-Next-Token: page2\r\n";
            } else {
                for (const QJsonObject &q : downloadQueue) qsos.append(q);
                downloadQueue.clear();
            }
            out = QJsonDocument(QJsonObject{{"qsos", qsos}}).toJson();
        } else if (url.path() == "/logbook/delete") {
            QJsonArray results;
            for (const QJsonValue &v : in["qso_ids"].toArray()) {
                deletes << v.toString();
                results.append(QJsonObject{{"qso_id", v}, {"action", "deleted"}});
            }
            out = QJsonDocument(QJsonObject{{"results", results}}).toJson();
        }
        int code = (failDeletes && url.path() == "/logbook/delete") ? 500 : status;
        s->write("HTTP/1.1 " + QByteArray::number(code) + " X\r\nContent-Type: application/json\r\n"
                 + extra + "Content-Length: " + QByteArray::number(out.size())
                 + "\r\nConnection: close\r\n\r\n" + out);
        s->disconnectFromHost();
    }
};

class DxqsoTest : public QObject
{
    Q_OBJECT

    FakeDxqso *api = nullptr;
    qsoModel *model = nullptr;
    dxqsoManager *dx = nullptr;

    int count(const QString &sql) {
        QSqlQuery q(sql);
        return q.next() ? q.value(0).toInt() : -1;
    }
    QString value(const QString &sql) {
        QSqlQuery q(sql);
        return q.next() ? q.value(0).toString() : QString();
    }
    void add(const QString &call, const QString &time, const QString &comm = QString()) {
        model->addQSO(call, "Name", "USA", "10.10.2026", time, "14.074", "FT8", "-10", "-12",
                      "FN31", "", comm, "", "", "", "", "", "", "", "", "", "", "", "", "FN42");
    }
    bool sync() {
        QSignalSpy done(dx, &dxqsoManager::busyChanged);
        dx->syncFromButton();
        while (dx->busy()) {
            if (!done.wait(5000)) return false;
        }
        return true;
    }
    int rowOf(const QString &call) {
        for (int r = 0; r < model->rowCount(); r++) {
            if (model->record(r).value("call").toString() == call) return r;
        }
        return -1;
    }

private slots:
    void initTestCase() {
        QCoreApplication::setOrganizationName("dxqso-test");
        QCoreApplication::setApplicationName("dxqso-test");
        QSettings().setValue("call", "N1EZ");

        QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
        db.setDatabaseName(":memory:");
        QVERIFY(db.open());
        QSqlQuery q;
        QVERIFY(q.exec("CREATE TABLE qsos(id INTEGER PRIMARY KEY, call TEXT, name TEXT, ctry TEXT,"
            " date TEXT, time TEXT, freq TEXT, mode TEXT, sent TEXT, recv TEXT, grid TEXT, qqth TEXT,"
            " comm TEXT, ctss TEXT, ctsr TEXT, sync INTEGER DEFAULT 0, sota TEXT, sots TEXT,"
            " satn TEXT, satm TEXT, wwff TEXT, wwfs TEXT, propmode TEXT, rxfreq TEXT, loca TEXT,"
            " pota TEXT, pots TEXT)"));

        api = new FakeDxqso;
        model = new qsoModel;
        dx = new dxqsoManager(model);
        dx->setVendorToken("vendor");
        connect(model, &qsoModel::qsoInserted, dx, &dxqsoManager::qsoInserted);
        connect(model, &qsoModel::qsoEdited, dx, &dxqsoManager::qsoEdited);
        connect(model, &qsoModel::qsoAboutToBeDeleted, dx, &dxqsoManager::qsoAboutToBeDeleted);
        // Send in real time off, so each step below runs exactly one sync.
        dx->configure(api->url(), "station.token.one", true, false, true);
        QTRY_VERIFY_WITH_TIMEOUT(!dx->busy(), 5000);
    }

    void recordColumnsMapping() {
        QVariantMap c = dxqsoManager::recordColumns(QJsonObject{
            {"call", "K1ABC"}, {"qso_date", "20261011"}, {"time_on", "140530"}, {"mode", "MFSK"},
            {"submode", "FT4"}, {"freq", 14.08}, {"stx", 5}, {"srx_string", "MA"},
            {"my_gridsquare", "FN42fw"}, {"pota_ref", "US-0001"}});
        QCOMPARE(c["date"].toString(), QString("11.10.2026"));
        QCOMPARE(c["time"].toString(), QString("14:05"));
        QCOMPARE(c["mode"].toString(), QString("MFSK / FT4"));
        QCOMPARE(c["freq"].toString(), QString("14.08"));
        QCOMPARE(c["ctss"].toString(), QString("5"));
        QCOMPARE(c["ctsr"].toString(), QString("MA"));
        QCOMPARE(c["loca"].toString(), QString("FN42fw"));
        QCOMPARE(c["pota"].toString(), QString("US-0001"));
        QVERIFY(!c.contains("name"));       // not in the record: left alone on an update
    }

    void uploadsNewQso() {
        add("W1AW", "12:00");
        QCOMPARE(dx->waitingCount(), 1);
        QVERIFY(sync());
        QCOMPARE(api->uploads.size(), 1);
        QJsonObject up = api->uploads.last();
        QCOMPARE(up["call"].toString(), QString("W1AW"));
        QCOMPARE(up["band"].toString(), QString("20m"));
        QCOMPARE(up["qso_date"].toString(), QString("20261010"));
        QCOMPARE(up["time_on"].toString(), QString("120000"));
        QCOMPARE(up["station_callsign"].toString(), QString("N1EZ"));
        QVERIFY(!up.contains("qso_id"));
        QVERIFY(!up.contains("qth"));       // empty fields are not sent
        QCOMPARE(value("SELECT qso_id FROM dxqso_qso"), QString("id-1"));
        QCOMPARE(dx->waitingCount(), 0);
        QVERIFY(sync());
        QCOMPARE(api->uploads.size(), 1);   // nothing sent twice
    }

    void echoUpdatesInPlace() {
        api->downloadQueue << QJsonObject{{"qso_id", "id-1"}, {"call", "W1AW"}, {"qso_date", "20261010"},
            {"time_on", "120000"}, {"band", "20M"}, {"mode", "FT8"}, {"comment", "from DxQSO"}};
        QVERIFY(sync());
        QCOMPARE(count("SELECT COUNT(*) FROM qsos"), 1);
        QCOMPARE(value("SELECT comm FROM qsos"), QString("from DxQSO"));
        QVERIFY(api->downloadQueries.last().contains("qso_since"));
        QCOMPARE(api->uploads.size(), 1);   // a download is never sent back
    }

    void echoOfOwnUploadChangesNothing() {
        // What DxQSO sends back for this log's own QSO, frequency formatted its way.
        api->downloadQueue << QJsonObject{{"qso_id", "id-1"}, {"call", "W1AW"}, {"qso_date", "20261010"},
            {"time_on", "120000"}, {"band", "20M"}, {"freq", "14.074000"}, {"mode", "FT8"},
            {"comment", "from DxQSO"}};
        QVERIFY(sync());
        QVERIFY2(!dx->status().contains("updated"), qPrintable(dx->status()));
        QCOMPARE(value("SELECT freq FROM qsos WHERE call = 'W1AW'"), QString("14.074"));
    }

    void editSendsQsoId() {
        int row = rowOf("W1AW");
        model->updateQSO(row, "W1AW", "Name", "USA", "10.10.2026", "12:00", "14.074", "FT8", "-10",
                         "-12", "FN31", "", "edited here", "", "", "", "", "", "", "", "", "", "",
                         "", "", "FN42");
        QCOMPARE(value("SELECT status FROM dxqso_qso"), QString("M"));
        QVERIFY(sync());
        QCOMPARE(api->uploads.last()["qso_id"].toString(), QString("id-1"));
        QCOMPARE(api->uploads.last()["comment"].toString(), QString("edited here"));
        QCOMPARE(value("SELECT status FROM dxqso_qso"), QString("Y"));
    }

    void localEditWinsOverDownload() {
        add("W2KEEP", "12:30");
        QVERIFY(sync());
        QString id = value("SELECT x.qso_id FROM dxqso_qso x JOIN qsos q ON q.id = x.qso_rowid"
                           " WHERE q.call = 'W2KEEP'");
        model->updateQSO(rowOf("W2KEEP"), "W2KEEP", "Name", "USA", "10.10.2026", "12:30", "14.074",
                         "FT8", "-10", "-12", "FN31", "", "mine", "", "", "", "", "", "", "", "", "",
                         "", "", "", "FN42");
        // The upload gets no answer, so the edit is still unsent when the download arrives.
        api->noVerdictFor = "W2KEEP";
        api->downloadQueue << QJsonObject{{"qso_id", id}, {"call", "W2KEEP"}, {"qso_date", "20261010"},
            {"time_on", "123000"}, {"band", "20M"}, {"comment", "theirs"}};
        QVERIFY(sync());
        api->noVerdictFor.clear();
        QCOMPARE(value("SELECT comm FROM qsos WHERE call = 'W2KEEP'"), QString("mine"));
        QVERIFY(sync());
        QCOMPARE(api->uploads.last()["comment"].toString(), QString("mine"));
        QCOMPARE(api->uploads.last()["qso_id"].toString(), id);
    }

    void downloadAddsAndDeletes() {
        api->downloadQueue << QJsonObject{{"qso_id", "id-99"}, {"call", "K1ABC"}, {"qso_date", "20261011"},
            {"time_on", "0900"}, {"band", "40M"}, {"freq", "7.074"}, {"mode", "FT8"}}
            << QJsonObject{{"qso_id", "id-98"}, {"call", "K2XYZ"}, {"qso_date", "20261011"},
            {"time_on", "0905"}, {"band", "40M"}, {"mode", "CW"}};
        QVERIFY(sync());
        QCOMPARE(api->nextTokens.last(), QByteArray("page2"));     // second page followed
        QCOMPARE(count("SELECT COUNT(*) FROM qsos"), 4);
        QCOMPARE(count("SELECT sync FROM qsos WHERE call = 'K1ABC'"), 1);   // not re-sent to Cloudlog
        QCOMPARE(dx->waitingCount(), 0);

        api->downloadQueue << QJsonObject{{"qso_id", "id-99"}, {"deleted", true}};
        int deletesBefore = api->deletes.size();
        QVERIFY(sync());
        QCOMPARE(count("SELECT COUNT(*) FROM qsos WHERE call = 'K1ABC'"), 0);
        QCOMPARE(count("SELECT COUNT(*) FROM dxqso_qso WHERE qso_id = 'id-99'"), 0);
        QCOMPARE(api->deletes.size(), deletesBefore);  // a delete from DxQSO is not sent back
    }

    void localDeleteIsSent() {
        QVERIFY(sync());
        model->deleteQSO(rowOf("K2XYZ"));
        QCOMPARE(count("SELECT COUNT(*) FROM dxqso_pending_deletes"), 1);
        QVERIFY(sync());
        QVERIFY(api->deletes.contains("id-98"));
        QCOMPARE(count("SELECT COUNT(*) FROM dxqso_pending_deletes"), 0);
    }

    void badFrequencyIsCaughtHere() {
        int before = api->uploads.size();
        model->addQSO("K2EZ", "Name", "USA", "13.10.2026", "03:30", "14.1.1", "SSB", "59", "59",
                      "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
        QSignalSpy failed(dx, &dxqsoManager::syncFailed);
        QVERIFY(sync());
        QCOMPARE(api->uploads.size(), before);          // never sent
        QCOMPARE(failed.size(), 1);                      // the button says why
        QStringList rejected = dx->rejectedQsos();
        QVERIFY2(rejected.join("|").contains("K2EZ 13.10.2026 03:30") &&
                 rejected.join("|").contains("14.1.1"), qPrintable(rejected.join("|")));
        // Fixed by an edit, it goes.
        model->updateQSO(rowOf("K2EZ"), "K2EZ", "Name", "USA", "13.10.2026", "03:30", "14.1", "SSB",
                         "59", "59", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
        QVERIFY(sync());
        QCOMPARE(api->uploads.last()["call"].toString(), QString("K2EZ"));
        QVERIFY(!dx->rejectedQsos().join("|").contains("K2EZ"));
    }

    void unsentDeleteIsNotUndone() {
        add("W3GONE", "11:00");
        QVERIFY(sync());
        QString id = value("SELECT x.qso_id FROM dxqso_qso x JOIN qsos q ON q.id = x.qso_rowid"
                           " WHERE q.call = 'W3GONE'");
        model->deleteQSO(rowOf("W3GONE"));
        // The delete fails, and the download still holds the record (not yet deleted there).
        api->failDeletes = true;
        api->downloadQueue << QJsonObject{{"qso_id", id}, {"call", "W3GONE"}, {"qso_date", "20261010"},
            {"time_on", "110000"}, {"band", "20M"}, {"mode", "FT8"}};
        QVERIFY(sync());
        QCOMPARE(count("SELECT COUNT(*) FROM qsos WHERE call = 'W3GONE'"), 0);
        QCOMPARE(count("SELECT COUNT(*) FROM dxqso_pending_deletes"), 1);
        api->failDeletes = false;
        QVERIFY(sync());
        QVERIFY(api->deletes.contains(id));
        QCOMPARE(count("SELECT COUNT(*) FROM dxqso_pending_deletes"), 0);
    }

    void sameQsoLoggedTwiceIsMerged() {
        // Logged elsewhere, arrives by download...
        api->naturalKeys.insert("K9DUP|20261010|1600", "id-500");
        api->downloadQueue << QJsonObject{{"qso_id", "id-500"}, {"call", "K9DUP"}, {"qso_date", "20261010"},
            {"time_on", "1600"}, {"band", "20M"}, {"freq", "14.074"}, {"mode", "FT8"}};
        QVERIFY(sync());
        QCOMPARE(count("SELECT COUNT(*) FROM qsos WHERE call = 'K9DUP'"), 1);
        // ...and then logged here as well.
        add("K9DUP", "16:00", "logged here too");
        QVERIFY(sync());
        QCOMPARE(count("SELECT COUNT(*) FROM qsos WHERE call = 'K9DUP'"), 1);
        QCOMPARE(count("SELECT COUNT(*) FROM dxqso_qso WHERE qso_id = 'id-500'"), 1);
        QVERIFY2(dx->status().contains("merged"), qPrintable(dx->status()));
        QCOMPARE(dx->waitingCount(), 0);
    }

    void reusedRowIdDoesNotInheritAnId() {
        // Delete All clears the device only, and the next QSO may get the same row id.
        QSqlQuery("DELETE FROM qsos");
        QCOMPARE(count("SELECT COUNT(*) FROM dxqso_qso"), 0);
        add("N0NEW", "13:00");
        QCOMPARE(dx->waitingCount(), 1);
        QVERIFY(sync());
        QVERIFY(!api->uploads.last().contains("qso_id"));
    }

    void rejectedIsReported() {
        add("REJECT", "13:30");
        QSignalSpy failed(dx, &dxqsoManager::syncFailed);
        QVERIFY(sync());
        QCOMPARE(failed.size(), 1);
        QCOMPARE(value("SELECT x.status FROM dxqso_qso x JOIN qsos q ON q.id = x.qso_rowid"
                       " WHERE q.call = 'REJECT'"), QString("R"));
        QVERIFY(dx->rejectedQsos().join("|").contains("REJECT 10.10.2026 13:30 — test"));
        QCOMPARE(dx->waitingCount(), 0);    // not retried until edited
    }

    void refusedKeyStopsSync() {
        api->status = 401;
        api->errorBody = R"({"error":"UNAUTHORIZED","message":"expired"})";
        add("N0LATE", "14:00");
        QVERIFY(sync());
        api->status = 200;
        int before = api->uploads.size();
        QSignalSpy failed(dx, &dxqsoManager::syncFailed);
        dx->syncFromButton();
        QCOMPARE(failed.size(), 1);         // refused until the key changes
        QVERIFY(!dx->busy());
        dx->configure(api->url(), "station.token.two", true, false, true);
        QTRY_VERIFY_WITH_TIMEOUT(!dx->busy(), 5000);
        QVERIFY(sync());
        QVERIFY(api->uploads.size() > before);
        // A new key starts downloads afresh.
        QVERIFY(!api->downloadQueries.last().contains("qso_since"));
    }

    void readOnlyKeyDoesNotStopSync() {
        api->status = 403;
        api->errorBody = R"({"error":"READ_ONLY_KEY","message":"read-only"})";
        add("N0RO", "15:00");
        QVERIFY(sync());
        api->status = 200;
        QVERIFY(sync());
        QCOMPARE(api->uploads.last()["call"].toString(), QString("N0RO"));
    }

    void describesKeys() {
        // {"token_type":"account","scope":"account_read","callsigns":["N1EZ"],"exp":1900000000}
        QByteArray claims = QJsonDocument(QJsonObject{{"token_type", "account"}, {"scope", "account_read"},
            {"callsigns", QJsonArray{"N1EZ"}}, {"exp", 1900000000}}).toJson(QJsonDocument::Compact)
            .toBase64(QByteArray::Base64UrlEncoding | QByteArray::OmitTrailingEquals);
        QString d = dx->describeKey("x." + claims + ".sig123");
        QVERIFY(d.contains("read-only"));
        QVERIFY(d.contains("only N1EZ"));
        QVERIFY(d.endsWith("sig123)"));
        QVERIFY(dx->describeKey("nonsense").startsWith("Not a DxQSO key"));
    }
};

QTEST_GUILESS_MAIN(DxqsoTest)
#include "dxqso_t.moc"
