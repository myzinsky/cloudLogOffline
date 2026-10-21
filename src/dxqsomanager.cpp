#include "dxqsomanager.h"

#include <QCryptographicHash>
#include <QDateTime>
#include <QGuiApplication>
#include <QJsonDocument>
#include <QRegularExpression>
#include <QSqlError>
#include <QUrlQuery>

// The vendor token names the app to DxQSO; it is not a secret (access rests on the operator's
// own station token or account key). Baked in at build time:
//   cmake -DDXQSO_VENDOR_TOKEN=... ; the repository copy stays empty.
#ifndef DXQSO_VENDOR_TOKEN
#define DXQSO_VENDOR_TOKEN ""
#endif

static const int UPLOAD_BATCH = 500;        // DxQSO accepts up to 2000 per request
static const int DELETE_BATCH = 1000;       // DxQSO accepts up to 2000 per request
static const int DOWNLOAD_OVERLAP = 120;    // seconds re-read on each download, for clock skew
static const int SYNC_MINUTES = 15;         // while the app is open

dxqsoManager::dxqsoManager(qsoModel *model) : model(model), vendorToken(DXQSO_VENDOR_TOKEN)
{
    manager = new QNetworkAccessManager(this);
    ensureSchema();

    timer.setInterval(SYNC_MINUTES * 60 * 1000);
    connect(&timer, &QTimer::timeout, this, &dxqsoManager::syncNow);
    timer.start();

    // Coming back to the app is when a phone is most likely to be online again.
    if (qGuiApp) connect(qGuiApp, &QGuiApplication::applicationStateChanged, this, [this](Qt::ApplicationState s) {
        if (s == Qt::ApplicationActive) {
            syncNow();
        }
    });
}

/* ── Settings ──────────────────────────────────────────────────────────────────────── */

/* Called by the settings page on every save, and once at start-up. */
void dxqsoManager::configure(QString apiUrl, QString token, bool active, bool realtime, bool download)
{
    QString url = apiUrl.trimmed();
    while (url.endsWith("/")) {
        url.chop(1);
    }
    if (url.isEmpty()) {
        url = "https://api.dxqso.net";
    }
    if (!url.startsWith("http://") && !url.startsWith("https://")) {
        url = "https://" + url;
    }
    bool first = this->apiUrl.isEmpty();
    this->apiUrl = url;
    this->token = token.trimmed();
    this->active = active;
    this->realtime = realtime;
    this->download = download;

    // A different key (or server) is a different log: downloads start afresh. QSOs keep their
    // DxQSO ids, so turning sync back on does not send them twice.
    QString hash = tokenHash(this->apiUrl + "|" + this->token);
    if (!this->token.isEmpty() && state("key") != hash) {
        setState("key", hash);
        setState("synced_until", "");
        setState("refused", "");
    }
    if (first) {
        syncNow();
    }
}

bool dxqsoManager::hasVendorToken() const
{
    return !vendorToken.isEmpty();
}

bool dxqsoManager::canSync() const
{
    return active && !token.isEmpty() && hasVendorToken()
        && state("refused") != tokenHash(apiUrl + "|" + token);
}

QString dxqsoManager::tokenHash(const QString &t) const
{
    return QString(QCryptographicHash::hash(t.toUtf8(), QCryptographicHash::Sha256).toHex());
}

/*
 * What a key is, for the settings page: read from its own claims, never verified here
 * (DxQSO does that). Ends with the key's last 6 characters, as DxQSO's Stations page lists
 * keys, so the two can be matched by eye.
 */
QString dxqsoManager::describeKey(QString t) const
{
    t = t.trimmed();
    if (t.isEmpty()) {
        return "";
    }
    QString end = QString::fromUtf8("…") + t.right(6);
    QStringList parts = t.split('.');
    QJsonObject claims;
    if (parts.size() == 3) {
        QByteArray raw = QByteArray::fromBase64(parts[1].toUtf8(),
                QByteArray::Base64UrlEncoding | QByteArray::OmitTrailingEquals);
        claims = QJsonDocument::fromJson(raw).object();
    }
    if (claims.isEmpty()) {
        return tr("Not a DxQSO key (%1)").arg(end);
    }
    QString expires = claims.contains("exp")
        ? QDateTime::fromSecsSinceEpoch(claims["exp"].toVariant().toLongLong(), Qt::UTC).toString("yyyy-MM-dd")
        : "?";
    if (claims["token_type"].toString() == "account") {
        QStringList calls;
        for (const QJsonValue &c : claims["callsigns"].toArray()) {
            if (!c.toString().isEmpty()) {
                calls << c.toString();
            }
        }
        return tr("Account key, %1, %2, expires %3 (%4)")
            .arg(claims["scope"].toString() == "account_read" ? tr("read-only") : tr("read-write"))
            .arg(calls.isEmpty() ? tr("every callsign") : tr("only %1").arg(calls.join(", ")))
            .arg(expires, end);
    }
    return tr("Station token, expires %1 (%2)").arg(expires, end);
}

/* QSOs waiting to be sent: never sent, or edited since. */
int dxqsoManager::waitingCount() const
{
    QSqlQuery q;
    q.exec("SELECT COUNT(*) FROM qsos q LEFT JOIN dxqso_qso x ON x.qso_rowid = q.id"
           " WHERE x.qso_rowid IS NULL OR x.status = 'M'");
    return q.next() ? q.value(0).toInt() : 0;
}

/* ── Schema (own tables, created on first use) ─────────────────────────────────────── */

void dxqsoManager::ensureSchema()
{
    QSqlQuery q;
    const char *statements[] = {
        "CREATE TABLE IF NOT EXISTS dxqso_qso ("
        " qso_rowid INTEGER PRIMARY KEY,"
        " qso_id TEXT,"
        " status TEXT NOT NULL,"       // Y sent, M changed since, R rejected
        " uploaded_at TEXT)",
        "CREATE INDEX IF NOT EXISTS idx_dxqso_qso_id ON dxqso_qso (qso_id)",
        "CREATE TABLE IF NOT EXISTS dxqso_pending_deletes ("
        " id INTEGER PRIMARY KEY,"
        " qso_id TEXT NOT NULL,"
        " created_at TEXT NOT NULL)",
        "CREATE TABLE IF NOT EXISTS dxqso_state (name TEXT PRIMARY KEY, value TEXT)",
        // Every delete of a QSO, by any path (one at a time, Delete All, a download), takes its
        // mapping with it. SQLite reuses the highest row id, so a stale mapping would hand the
        // next QSO logged someone else's DxQSO id.
        "CREATE TRIGGER IF NOT EXISTS dxqso_qso_gone AFTER DELETE ON qsos"
        " BEGIN DELETE FROM dxqso_qso WHERE qso_rowid = OLD.id; END",
    };
    for (const char *s : statements) {
        if (!q.exec(s)) {
            qDebug() << "DxQSO schema:" << q.lastError().text();
        }
    }
    // Why a QSO was rejected (status R). Added after the first test builds.
    if (!QSqlDatabase::database().record("dxqso_qso").contains("reason")) {
        q.exec("ALTER TABLE dxqso_qso ADD COLUMN reason TEXT");
    }
    // Mappings left by a build without the trigger.
    q.exec("DELETE FROM dxqso_qso WHERE qso_rowid NOT IN (SELECT id FROM qsos)");
}

QString dxqsoManager::state(const QString &name) const
{
    QSqlQuery q;
    q.prepare("SELECT value FROM dxqso_state WHERE name = ?");
    q.addBindValue(name);
    return (q.exec() && q.next()) ? q.value(0).toString() : QString();
}

void dxqsoManager::setState(const QString &name, const QString &value)
{
    QSqlQuery q;
    q.prepare("INSERT OR REPLACE INTO dxqso_state (name, value) VALUES (?, ?)");
    q.addBindValue(name);
    q.addBindValue(value);
    q.exec();
}

void dxqsoManager::setQsoState(int id, const QString &status, const QString &qsoId, const QString &reason)
{
    QSqlQuery q;
    QString now = QDateTime::currentDateTimeUtc().toString(Qt::ISODate);
    QVariant why = reason.isEmpty() ? QVariant() : QVariant(reason);
    if (!qsoId.isEmpty()) {
        q.prepare("INSERT INTO dxqso_qso (qso_rowid, qso_id, status, uploaded_at, reason) VALUES (?, ?, ?, ?, ?)"
                  " ON CONFLICT(qso_rowid) DO UPDATE SET qso_id = excluded.qso_id,"
                  " status = excluded.status, uploaded_at = excluded.uploaded_at, reason = excluded.reason");
        q.addBindValue(id);
        q.addBindValue(qsoId);
    } else {
        // No id given: keep the one already held.
        q.prepare("INSERT INTO dxqso_qso (qso_rowid, status, uploaded_at, reason) VALUES (?, ?, ?, ?)"
                  " ON CONFLICT(qso_rowid) DO UPDATE SET status = excluded.status,"
                  " uploaded_at = excluded.uploaded_at, reason = excluded.reason");
        q.addBindValue(id);
    }
    q.addBindValue(status);
    q.addBindValue(now);
    q.addBindValue(why);
    if (!q.exec()) {
        qDebug() << "DxQSO state:" << q.lastError().text();
    }
}

QStringList dxqsoManager::rejectedQsos() const
{
    QStringList out;
    QSqlQuery q("SELECT q.call, q.date, q.time, coalesce(x.reason, '') FROM qsos q"
                " JOIN dxqso_qso x ON x.qso_rowid = q.id WHERE x.status = 'R' ORDER BY q.id");
    while (q.next()) {
        QString line = q.value(0).toString() + " " + q.value(1).toString() + " " + q.value(2).toString();
        if (!q.value(3).toString().isEmpty()) {
            line += QString::fromUtf8(" — ") + q.value(3).toString();
        }
        out << line;
    }
    return out;
}

/* ── QSO events (fired by qsoModel) ────────────────────────────────────────────────── */

void dxqsoManager::qsoInserted(int id)
{
    Q_UNUSED(id);
    if (realtime) {
        startRun(false);
    }
}

/* An edited QSO already sent (or rejected) is sent again, with its DxQSO id. */
void dxqsoManager::qsoEdited(int id)
{
    QSqlQuery q;
    q.prepare("UPDATE dxqso_qso SET status = 'M' WHERE qso_rowid = ? AND status IN ('Y', 'R')");
    q.addBindValue(id);
    q.exec();
    if (realtime) {
        startRun(false);
    }
}

/*
 * A QSO is about to be deleted here: delete it on DxQSO too. Queued, and sent now when QSOs
 * are sent as they are saved. Downloads delete with SQL of their own, so a deletion that came
 * FROM DxQSO never comes through here and is not sent back.
 */
void dxqsoManager::qsoAboutToBeDeleted(int id)
{
    QSqlQuery q;
    q.prepare("SELECT qso_id FROM dxqso_qso WHERE qso_rowid = ?");
    q.addBindValue(id);
    if (!q.exec() || !q.next()) {
        return;     // never sent: nothing to delete on DxQSO
    }
    QString qsoId = q.value(0).toString();
    if (qsoId.isEmpty() || token.isEmpty()) {
        return;
    }
    QSqlQuery ins;
    ins.prepare("INSERT INTO dxqso_pending_deletes (qso_id, created_at) VALUES (?, ?)");
    ins.addBindValue(qsoId);
    ins.addBindValue(QDateTime::currentDateTimeUtc().toString(Qt::ISODate));
    ins.exec();
    if (realtime) {
        startRun(false);
    }
}

/* ── Runs ──────────────────────────────────────────────────────────────────────────── */

void dxqsoManager::syncNow()
{
    startRun(download);
}

void dxqsoManager::syncFromButton()
{
    if (!hasVendorToken()) {
        emit syncFailed(tr("This build has no DxQSO vendor token, so it cannot reach DxQSO."));
        return;
    }
    if (!canSync()) {
        emit syncFailed(active && !token.isEmpty()
            ? tr("DxQSO refused this key. Enter a new one in Settings.")
            : tr("Turn on DxQSO Sync and enter a key in Settings first."));
        return;
    }
    startRun(download, true);
}

/* One run: queued deletes, then uploads, then (withDownload) the download. One at a time. */
void dxqsoManager::startRun(bool withDownload, bool manual)
{
    if (!canSync()) {
        return;
    }
    if (running) {
        rerun = true;
        rerunDownload = rerunDownload || withDownload;
        rerunManual = rerunManual || manual;
        return;
    }
    running = true;
    emit busyChanged();
    runDownload = withDownload;
    manualRun = manual;
    startedAt = QDateTime::currentDateTimeUtc().toString(Qt::ISODate);
    lastUploadedId = 0;
    sent = rejected = deleted = merged = 0;
    inserted = updated = linked = removed = skipped = 0;
    errors.clear();
    stepDeletes();
}

void dxqsoManager::finishRun(const QString &fatal)
{
    if (!fatal.isEmpty()) {
        errors.prepend(fatal);
    }
    QStringList parts;
    if (sent)     parts << tr("%n sent", "", sent);
    if (deleted)  parts << tr("%n deleted on DxQSO", "", deleted);
    if (inserted) parts << tr("%n new from DxQSO", "", inserted);
    if (updated)  parts << tr("%n updated from DxQSO", "", updated);
    if (linked)   parts << tr("%n matched", "", linked);
    if (removed)  parts << tr("%n removed (deleted on DxQSO)", "", removed);
    if (rejected) parts << tr("%n rejected", "", rejected);
    if (merged)   parts << tr("%n duplicate(s) merged", "", merged);
    QString summary = parts.isEmpty() ? tr("Up to date") : parts.join(", ");
    lastStatus = QDateTime::currentDateTime().toString("HH:mm") + " " + summary
        + (errors.isEmpty() ? "" : " — " + errors.first());
    emit statusChanged();

    if (inserted || updated || removed || linked || sent || rejected || merged) {
        model->select();
        emit model->updateNumberOfQSOs(model->numberOfQSOs());
    }
    running = false;
    emit busyChanged();
    // An automatic run (a saved QSO, the timer, coming back to the app) only updates the status
    // line: offline in the field, every QSO saved would otherwise raise a dialog.
    if (manualRun && !errors.isEmpty()) {
        emit syncFailed(errors.join("\n"));
    } else {
        // Also after an automatic run that hit errors: the page refreshes what it shows, and
        // the errors stay on the status line and in the rejected list.
        emit syncFinished(summary);
    }
    if (rerun) {
        bool d = rerunDownload, m = rerunManual;
        rerun = rerunDownload = rerunManual = false;
        startRun(d, m);
    }
}

/* ── HTTP ──────────────────────────────────────────────────────────────────────────── */

QNetworkRequest dxqsoManager::request(const QString &path, const QString &query,
                                      const QString &base, const QString &key) const
{
    QUrl url((base.isEmpty() ? apiUrl : base) + path);
    if (!query.isEmpty()) {
        url.setQuery(query);
    }
    QNetworkRequest r(url);
    r.setRawHeader("Authorization", "Bearer " + vendorToken.toUtf8());
    r.setRawHeader("dxqso-station-token", "Bearer " + (key.isEmpty() ? token : key).toUtf8());
    r.setRawHeader("Accept", "application/json");
    r.setRawHeader("User-Agent", "CloudLogOffline/" + QByteArray(GIT_VERSION) + " DxQSO-sync");
#if QT_VERSION >= QT_VERSION_CHECK(5, 15, 0)
    r.setTransferTimeout(120000);
#endif
    return r;
}

/*
 * Is the key itself refused, so syncing should stop until it is changed? Every 401 is, and a
 * 403 only for a revoked or inactive key. Any other 403 is about the request, not the key:
 * READ_ONLY_KEY (a read-only account key asked to upload or delete) must not stop the
 * download as well. It is reported and retried instead.
 */
bool dxqsoManager::tokenRefused(QNetworkReply *rep, const QJsonObject &body)
{
    int code = rep->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    if (code == 401) {
        return true;
    }
    static const QStringList refused = {"STATION_REVOKED", "STATION_INACTIVE",
        "ACCOUNT_KEY_REVOKED", "VENDOR_INACTIVE", "VENDOR_EXPIRED"};
    return code == 403 && refused.contains(body["error"].toString());
}

void dxqsoManager::refuseToken()
{
    setState("refused", tokenHash(apiUrl + "|" + token));
}

static QString httpError(QNetworkReply *rep, const QJsonObject &body)
{
    int code = rep->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    if (code == 0) {
        return rep->errorString();
    }
    QString msg = body["message"].toString();
    if (msg.isEmpty()) {
        msg = body["error"].toString();
    }
    return QString("HTTP %1 %2").arg(code).arg(msg).trimmed();
}

/* ── Deletes ───────────────────────────────────────────────────────────────────────── */

void dxqsoManager::stepDeletes()
{
    QSqlQuery q;
    q.exec(QString("SELECT DISTINCT qso_id FROM dxqso_pending_deletes ORDER BY id LIMIT %1").arg(DELETE_BATCH));
    batchDeleteIds.clear();
    QJsonArray ids;
    while (q.next()) {
        batchDeleteIds << q.value(0).toString();
        ids.append(q.value(0).toString());
    }
    if (batchDeleteIds.isEmpty()) {
        stepUpload();
        return;
    }
    QJsonObject body{{"qso_ids", ids}};
    QNetworkRequest r = request("/logbook/delete");
    r.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    QNetworkReply *rep = manager->post(r, QJsonDocument(body).toJson(QJsonDocument::Compact));
    connect(rep, &QNetworkReply::finished, this, [this, rep]() {
        rep->deleteLater();
        QJsonObject resp = QJsonDocument::fromJson(rep->readAll()).object();
        if (tokenRefused(rep, resp)) {
            refuseToken();
            finishRun(tr("DxQSO refused the key. Enter a new one in Settings to sync again."));
            return;
        }
        int code = rep->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        if (code != 200) {
            // Kept in the queue for the next run; uploads still go.
            errors << tr("Deleting QSOs on DxQSO failed (%1); they will be sent again.").arg(httpError(rep, resp));
            stepUpload();
            return;
        }
        // Every id DxQSO answered is settled: deleted, not found, or a confirmed QSL it refuses
        // to delete (that QSO comes back on the next full download).
        QSqlQuery del;
        for (const QString &id : batchDeleteIds) {
            del.prepare("DELETE FROM dxqso_pending_deletes WHERE qso_id = ?");
            del.addBindValue(id);
            del.exec();
        }
        for (const QJsonValue &v : resp["results"].toArray()) {
            QJsonObject r = v.toObject();
            if (r["action"].toString() == "deleted") {
                deleted++;
            } else if (r["action"].toString() == "rejected") {
                errors << tr("DxQSO kept QSO %1: %2").arg(r["qso_id"].toString(), r["reason"].toString());
            }
        }
        stepDeletes();
    });
}

/* ── Upload ────────────────────────────────────────────────────────────────────────── */

/* {name: value} from one ADIF record. Field lengths are honoured, so values may hold '<'. */
static QJsonObject parseAdifRecord(const QString &adif)
{
    QJsonObject out;
    static const QRegularExpression tag("<([A-Za-z0-9_]+):(\\d+)(?::[^>]*)?>");
    int pos = 0;
    while (true) {
        QRegularExpressionMatch m = tag.match(adif, pos);
        if (!m.hasMatch()) {
            break;
        }
        int len = m.captured(2).toInt();
        int start = m.capturedEnd(0);
        QString value = adif.mid(start, len);
        // Empty fields are left out: an edit must not blank what DxQSO holds and this log
        // never had (a downloaded QSO's LoTW/QRZ details, say).
        if (!value.isEmpty()) {
            out[m.captured(1).toLower()] = value;
        }
        pos = start + len;
    }
    return out;
}

/* A QSO as DxQSO's JSON upload takes it: the fields the ADIF export writes, lower-case. */
QJsonObject dxqsoManager::qsoPayload(QSqlQuery &row)
{
    QString adifLine = adif.assemble(
        row.value("call").toString(), row.value("name").toString(), row.value("mode").toString(),
        row.value("freq").toString(), row.value("date").toString(), row.value("time").toString(),
        row.value("recv").toString(), row.value("sent").toString(), row.value("ctry").toString(),
        row.value("grid").toString(), row.value("qqth").toString(), row.value("comm").toString(),
        row.value("ctss").toString(), row.value("ctsr").toString(), row.value("sota").toString(),
        row.value("sots").toString(), row.value("wwff").toString(), row.value("wwfs").toString(),
        row.value("pota").toString(), row.value("pots").toString(), row.value("satn").toString(),
        row.value("satm").toString(), row.value("propmode").toString(),
        row.value("rxfreq").toString(), row.value("loca").toString());
    QJsonObject qso = parseAdifRecord(adifLine);
    QString qsoId = row.value("dxqso_qso_id").toString();
    if (!qsoId.isEmpty()) {
        qso["qso_id"] = qsoId;      // edit that record, do not add another
    }
    return qso;
}

void dxqsoManager::stepUpload()
{
    QSqlQuery q;
    q.prepare(QString("SELECT q.*, x.qso_id AS dxqso_qso_id FROM qsos q"
                      " LEFT JOIN dxqso_qso x ON x.qso_rowid = q.id"
                      " WHERE q.id > ? AND (x.qso_rowid IS NULL OR x.status = 'M')"
                      " ORDER BY q.id LIMIT %1").arg(UPLOAD_BATCH));
    q.addBindValue(lastUploadedId);
    q.exec();
    batchIds.clear();
    batchPayload = QJsonArray();
    bool any = false;
    while (q.next()) {
        any = true;
        int id = q.value("id").toInt();
        lastUploadedId = id;
        QJsonObject qso = qsoPayload(q);
        // DxQSO keys a QSO on call, date, time and band, and refuses one without a band. A
        // frequency that is not a number on an amateur band gives none: say so here, where the
        // operator can fix it, instead of sending it to be refused.
        if (qso["band"].toString().isEmpty()) {
            QString why = tr("frequency \"%1\" is not on an amateur band").arg(q.value("freq").toString());
            setQsoState(id, "R", QString(), why);
            rejected++;
            errors << tr("%1 %2 %3 not sent: %4").arg(q.value("call").toString(),
                q.value("date").toString(), q.value("time").toString(), why);
            continue;
        }
        batchIds << id;
        batchPayload.append(qso);
    }
    if (any && batchIds.isEmpty()) {
        stepUpload();       // the whole batch was refused here: carry on with the next one
        return;
    }
    if (batchIds.isEmpty()) {
        if (runDownload) {
            QUrlQuery query;
            query.addQueryItem("format", "json");
            QString since = state("synced_until");
            if (!since.isEmpty()) {
                QDateTime t = QDateTime::fromString(since, Qt::ISODate).addSecs(-DOWNLOAD_OVERLAP);
                query.addQueryItem("qso_since", t.toUTC().toString("yyyy-MM-ddTHH:mm:ssZ"));
            }
            downloadQuery = query.toString(QUrl::FullyEncoded);
            stepDownload(QByteArray());
        } else {
            finishRun();
        }
        return;
    }
    QJsonObject body{{"qsos", batchPayload}};
    QNetworkRequest r = request("/upload");
    r.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    QNetworkReply *rep = manager->post(r, QJsonDocument(body).toJson(QJsonDocument::Compact));
    connect(rep, &QNetworkReply::finished, this, [this, rep]() {
        rep->deleteLater();
        QJsonObject resp = QJsonDocument::fromJson(rep->readAll()).object();
        if (tokenRefused(rep, resp)) {
            refuseToken();
            finishRun(tr("DxQSO refused the key. Enter a new one in Settings to sync again."));
            return;
        }
        int code = rep->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        QJsonArray results = resp["results"].toArray();
        if (code != 200 || !resp["results"].isArray()) {
            // Left waiting; the next run tries again.
            finishRun(tr("DxQSO upload failed: %1").arg(httpError(rep, resp)));
            return;
        }
        // One result per record, in order; the echoed call/date/time confirm the pairing, and a
        // mismatch falls back to a search.
        auto same = [](const QJsonObject &r, const QJsonObject &s) {
            return r["call"].toString().toUpper() == s["call"].toString().toUpper()
                && r["qso_date"].toString() == s["qso_date"].toString()
                && r["time_on"].toString().left(4) == s["time_on"].toString().left(4);
        };
        for (int i = 0; i < batchIds.size(); i++) {
            QJsonObject s = batchPayload[i].toObject();
            QJsonObject r;
            if (i < results.size() && same(results[i].toObject(), s)) {
                r = results[i].toObject();
            } else {
                for (const QJsonValue &v : results) {
                    if (same(v.toObject(), s)) {
                        r = v.toObject();
                        break;
                    }
                }
            }
            if (r.isEmpty()) {
                continue;   // no verdict for this QSO: left waiting, the next run retries
            }
            if (r["action"].toString() == "rejected") {
                // An edit here sets it back to M and it is tried again.
                setQsoState(batchIds[i], "R", QString(), r["reason"].toString());
                rejected++;
                errors << tr("DxQSO rejected %1 %2 %3: %4").arg(s["call"].toString(),
                    s["qso_date"].toString(), s["time_on"].toString(), r["reason"].toString());
                continue;
            }
            // DxQSO matched it (call, date, time, band) to a record another QSO here already
            // holds: the same QSO logged twice, once here and once arriving by download. DxQSO
            // applied this one's values to that record, and the other QSO receives them on
            // the next download, so this copy goes (straight SQL: nothing to delete there).
            QString qsoId = r["qso_id"].toString();
            QSqlQuery other;
            other.prepare("SELECT 1 FROM dxqso_qso WHERE qso_id = ? AND qso_rowid <> ? LIMIT 1");
            other.addBindValue(qsoId);
            other.addBindValue(batchIds[i]);
            if (!qsoId.isEmpty() && other.exec() && other.next()) {
                QSqlQuery drop;
                drop.prepare("DELETE FROM qsos WHERE id = ?");
                drop.addBindValue(batchIds[i]);
                drop.exec();
                merged++;
                continue;
            }
            setQsoState(batchIds[i], "Y", qsoId);
            sent++;
        }
        stepUpload();
    });
}

/* ── Download ──────────────────────────────────────────────────────────────────────── */

void dxqsoManager::stepDownload(const QByteArray &next)
{
    QNetworkRequest r = request("/logbook/download", downloadQuery);
    if (!next.isEmpty()) {
        r.setRawHeader("X-Next-Token", next);     // the page cursor travels as a header
    }
    QNetworkReply *rep = manager->get(r);
    connect(rep, &QNetworkReply::finished, this, [this, rep]() {
        rep->deleteLater();
        QJsonObject resp = QJsonDocument::fromJson(rep->readAll()).object();
        if (tokenRefused(rep, resp)) {
            refuseToken();
            finishRun(tr("DxQSO refused the key. Enter a new one in Settings to sync again."));
            return;
        }
        int code = rep->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        if (code != 200 || !resp["qsos"].isArray()) {
            finishRun(tr("DxQSO download failed: %1").arg(httpError(rep, resp)));
            return;
        }
        QSqlDatabase::database().transaction();
        for (const QJsonValue &v : resp["qsos"].toArray()) {
            applyRecord(v.toObject());
        }
        QSqlDatabase::database().commit();

        // A short (or empty) page is not the last one: follow the cursor until it is empty.
        QByteArray following = rep->rawHeader("X-Next-Token").trimmed();
        if (following.isEmpty()) {
            following = resp["next_token"].toString().toUtf8();
        }
        if (!following.isEmpty()) {
            stepDownload(following);
            return;
        }
        // Only a download that read every page moves the mark.
        setState("synced_until", startedAt);
        finishRun();
    });
}

/* '20261010' -> '10.10.2026' (how this log stores dates) */
static QString localDate(const QString &adifDate)
{
    QString d = adifDate;
    d.remove(QRegularExpression("\\D"));
    if (d.size() < 8) {
        return QString();
    }
    return d.mid(6, 2) + "." + d.mid(4, 2) + "." + d.left(4);
}

/* '140530' / '1405' / '14:05:30' -> '14:05' */
static QString localTime(const QString &adifTime)
{
    QString t = adifTime;
    t.remove(QRegularExpression("\\D"));
    if (t.size() < 4) {
        return QString();
    }
    return t.left(2) + ":" + t.mid(2, 2);
}

QVariantMap dxqsoManager::recordColumns(const QJsonObject &in)
{
    QHash<QString, QString> rec;
    for (auto it = in.begin(); it != in.end(); ++it) {
        if (!it.value().isArray() && !it.value().isObject() && !it.value().isNull()) {
            rec.insert(it.key().toUpper(), it.value().toVariant().toString());
        }
    }
    QVariantMap out;
    static const QList<QPair<const char *, const char *>> plain = {
        {"call", "CALL"}, {"name", "NAME"}, {"ctry", "COUNTRY"}, {"freq", "FREQ"},
        {"sent", "RST_SENT"}, {"recv", "RST_RCVD"}, {"grid", "GRIDSQUARE"}, {"qqth", "QTH"},
        {"comm", "COMMENT"}, {"sota", "SOTA_REF"}, {"sots", "MY_SOTA_REF"}, {"wwff", "WWFF_REF"},
        {"wwfs", "MY_WWFF_REF"}, {"pota", "POTA_REF"}, {"pots", "MY_POTA_REF"},
        {"satn", "SAT_NAME"}, {"satm", "SAT_MODE"}, {"propmode", "PROP_MODE"},
        {"rxfreq", "FREQ_RX"}, {"loca", "MY_GRIDSQUARE"},
    };
    for (const auto &p : plain) {
        if (rec.contains(p.second)) {
            out[p.first] = rec.value(p.second);
        }
    }
    if (rec.contains("QSO_DATE")) {
        out["date"] = localDate(rec.value("QSO_DATE"));
    }
    if (rec.contains("TIME_ON")) {
        out["time"] = localTime(rec.value("TIME_ON"));
    }
    // This log keeps MODE and SUBMODE together, as "MODE / SUBMODE".
    if (rec.contains("MODE")) {
        QString sub = rec.value("SUBMODE");
        out["mode"] = sub.isEmpty() ? rec.value("MODE") : rec.value("MODE") + " / " + sub;
    }
    // ...and the contest exchange as one field, number or text.
    if (rec.contains("STX_STRING") || rec.contains("STX")) {
        out["ctss"] = rec.value("STX_STRING", rec.value("STX"));
    }
    if (rec.contains("SRX_STRING") || rec.contains("SRX")) {
        out["ctsr"] = rec.value("SRX_STRING", rec.value("SRX"));
    }
    return out;
}

/*
 * The same QSO logged here before it ever went to DxQSO: call, date, time and band, among QSOs
 * that hold no DxQSO id. A QSO that already holds one is a DIFFERENT DxQSO record (the same
 * station worked again within the minute), so the download adds this one instead.
 */
int dxqsoManager::matchLocal(const QVariantMap &cols, const QString &band)
{
    QSqlQuery q;
    q.prepare("SELECT q.id, q.freq FROM qsos q LEFT JOIN dxqso_qso x ON x.qso_rowid = q.id"
              " WHERE upper(q.call) = upper(?) AND q.date = ? AND q.time = ?"
              " AND (x.qso_id IS NULL OR x.qso_id = '')");
    q.addBindValue(cols.value("call"));
    q.addBindValue(cols.value("date"));
    q.addBindValue(cols.value("time"));
    if (!q.exec()) {
        return 0;
    }
    while (q.next()) {
        QString local = adif.band(q.value(1).toString());
        if (band.isEmpty() || local.isEmpty() || local.compare(band, Qt::CaseInsensitive) == 0) {
            return q.value(0).toInt();
        }
    }
    return 0;
}

/* One downloaded record: delete, update, link or add. */
void dxqsoManager::applyRecord(QJsonObject in)
{
    QJsonObject record;
    for (auto it = in.begin(); it != in.end(); ++it) {
        record[it.key().toUpper()] = it.value();
    }
    QString qsoId = record["QSO_ID"].toString();
    if (qsoId.isEmpty()) {
        skipped++;
        return;
    }
    QSqlQuery find;
    find.prepare("SELECT q.id, x.status FROM dxqso_qso x JOIN qsos q ON q.id = x.qso_rowid"
                 " WHERE x.qso_id = ? LIMIT 1");
    find.addBindValue(qsoId);
    find.exec();
    int localId = 0;
    QString status;
    if (find.next()) {
        localId = find.value(0).toInt();
        status = find.value(1).toString();
    }

    QVariant del = record["DELETED"].toVariant();
    if (del.toBool() || del.toString().toLower() == "true") {
        if (localId) {
            // Straight SQL, not through the model: the delete came from DxQSO and must not be
            // sent back. The trigger takes the mapping with it.
            QSqlQuery q;
            q.prepare("DELETE FROM qsos WHERE id = ?");
            q.addBindValue(localId);
            q.exec();
            removed++;
        }
        return;
    }

    // Deleted here, and the delete not yet accepted by DxQSO: the record must not come back.
    QSqlQuery pending;
    pending.prepare("SELECT 1 FROM dxqso_pending_deletes WHERE qso_id = ? LIMIT 1");
    pending.addBindValue(qsoId);
    if (pending.exec() && pending.next()) {
        skipped++;
        return;
    }

    QVariantMap cols = recordColumns(record);

    if (localId) {
        if (status == "M") {
            skipped++;      // edited here and not yet sent: this side's edit wins
            return;
        }
        // Only what differs is written, so the echo of this log's own upload changes nothing.
        // Frequencies compare as numbers: DxQSO sends "14.074000" for "14.074".
        QSqlQuery cur;
        cur.prepare("SELECT * FROM qsos WHERE id = ?");
        cur.addBindValue(localId);
        QVariantMap changed;
        if (cur.exec() && cur.next()) {
            for (auto it = cols.begin(); it != cols.end(); ++it) {
                QString mine = cur.value(it.key()).toString();
                QString theirs = it.value().toString();
                bool same = (it.key() == "freq" || it.key() == "rxfreq")
                    ? (mine.toDouble() == theirs.toDouble() && mine.isEmpty() == theirs.isEmpty())
                    : mine == theirs;
                if (!same) {
                    changed[it.key()] = it.value();
                }
            }
        }
        if (!changed.isEmpty()) {
            QStringList sets;
            for (auto it = changed.begin(); it != changed.end(); ++it) {
                sets << "\"" + it.key() + "\" = ?";
            }
            QSqlQuery q;
            q.prepare("UPDATE qsos SET " + sets.join(", ") + " WHERE id = ?");
            for (auto it = changed.begin(); it != changed.end(); ++it) {
                q.addBindValue(it.value());
            }
            q.addBindValue(localId);
            if (!q.exec()) {
                errors << q.lastError().text();
                return;
            }
            updated++;
        }
        if (status != "Y") {
            setQsoState(localId, "Y");
        }
        return;
    }

    if (cols.value("call").toString().isEmpty() || cols.value("date").toString().isEmpty()) {
        skipped++;
        return;
    }
    QString band = record["BAND"].toString();
    if (band.isEmpty()) {
        band = adif.band(cols.value("freq").toString());
    }
    int match = matchLocal(cols, band);
    if (match) {
        setQsoState(match, "Y", qsoId);
        linked++;
        return;
    }

    // Added already marked as uploaded to Cloudlog (sync = 1): it came from DxQSO, not from
    // this log, and the Cloudlog upload must not send it on a second way.
    QStringList names, marks;
    for (auto it = cols.begin(); it != cols.end(); ++it) {
        names << "\"" + it.key() + "\"";
        marks << "?";
    }
    QSqlQuery q;
    q.prepare("INSERT INTO qsos (" + names.join(", ") + ", sync) VALUES (" + marks.join(", ") + ", 1)");
    for (auto it = cols.begin(); it != cols.end(); ++it) {
        q.addBindValue(it.value());
    }
    // The id comes from THIS insert or not at all: a refused insert must never hand this
    // record's DxQSO id to another QSO.
    if (!q.exec()) {
        errors << tr("%1 %2 %3 not added: %4").arg(cols.value("call").toString(),
            cols.value("date").toString(), cols.value("time").toString(), q.lastError().text());
        return;
    }
    int id = q.lastInsertId().toInt();
    if (!id) {
        return;
    }
    setQsoState(id, "Y", qsoId);
    inserted++;
}

/* ── Key test ──────────────────────────────────────────────────────────────────────── */

void dxqsoManager::testKey(QString url, QString t)
{
    if (!hasVendorToken()) {
        emit keyTestResult(false, tr("This build has no DxQSO vendor token, so it cannot reach DxQSO."));
        return;
    }
    QString base = url.trimmed();
    while (base.endsWith("/")) {
        base.chop(1);
    }
    if (base.isEmpty()) {
        base = "https://api.dxqso.net";
    }
    if (!base.startsWith("http://") && !base.startsWith("https://")) {
        base = "https://" + base;
    }
    QNetworkReply *rep = manager->get(request("/logbook/station/station_info/", QString(), base, t.trimmed()));
    connect(rep, &QNetworkReply::finished, this, [this, rep, t]() {
        rep->deleteLater();
        QJsonObject resp = QJsonDocument::fromJson(rep->readAll()).object();
        int code = rep->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        if (code != 200) {
            emit keyTestResult(false, tr("DxQSO refused it: %1").arg(httpError(rep, resp)));
            return;
        }
        QString what;
        if (resp["token_type"].toString() == "account") {
            what = tr("%n Station(s) on the account", "", resp["stations"].toArray().size());
        } else {
            what = tr("Station \"%1\"").arg(resp["station_name"].toString());
        }
        emit keyTestResult(true, what + " — " + describeKey(t));
    });
}
