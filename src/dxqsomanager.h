#ifndef DXQSOMANAGER_H
#define DXQSOMANAGER_H

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonArray>
#include <QJsonObject>
#include <QSqlQuery>
#include <QTimer>
#include <QVariantMap>

#include "qsomodel.h"
#include "adiftools.h"

/*
 * Two-way sync with DxQSO (https://dxqso.org, API: https://dxqso.org/api).
 *
 * The log is kept in step with ONE DxQSO Station, named by its station token (or an account
 * key, which reaches every Station on the account):
 *   - upload:   QSOs not yet sent and QSOs edited since. An edited QSO is sent WITH its DxQSO
 *               id, so DxQSO updates it instead of adding another.
 *   - download: everything changed on DxQSO since the last download (qso_since). A known id
 *               updates the local QSO, an unknown one is matched by call/date/time/band or
 *               added, and a deletion on DxQSO deletes the local QSO.
 *   - deletes:  deleting a synced QSO here deletes it on DxQSO (queued while DxQSO cannot be
 *               reached, sent by the next sync).
 *
 * The DxQSO id stored for each QSO is what stops a QSO echoing back and forth: a QSO this log
 * uploaded comes back in the next download with an id it already holds.
 *
 * Everything lives in tables of its own (created on first use), so the qsos table and the
 * Cloudlog upload (its sync column) are untouched:
 *   dxqso_qso              QSO id -> DxQSO id and status (Y sent, M changed since, R rejected).
 *                          A QSO with no row has never been sent. A trigger removes the row
 *                          when its QSO is deleted by any path, so a reused row id never
 *                          inherits another QSO's DxQSO id.
 *   dxqso_pending_deletes  deletes waiting to be sent
 *   dxqso_state            how far downloads have got, and which key DxQSO refused
 *
 * Bulk deletes (Export > Delete All / Delete Uploaded) clear the phone only: they are NOT
 * sent to DxQSO.
 */
class dxqsoManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(QString status READ status NOTIFY statusChanged)

public:
    dxqsoManager(qsoModel *model);

    bool busy() const { return running; }
    QString status() const { return lastStatus; }

    Q_INVOKABLE QString describeKey(QString token) const;
    Q_INVOKABLE int waitingCount() const;
    // QSOs DxQSO (or this log, before sending) refused, with why: "K2EZ 13.10.2026 03:30 — reason".
    Q_INVOKABLE QStringList rejectedQsos() const;
    Q_INVOKABLE bool hasVendorToken() const;

    // The tests (and a developer build) set it here; a tester build bakes it in.
    void setVendorToken(const QString &t) { vendorToken = t; }

    // A downloaded record as the qsos table holds it (column -> value), only the columns the
    // record carries. Public for the tests.
    static QVariantMap recordColumns(const QJsonObject &record);

public slots:
    void configure(QString apiUrl, QString token, bool active, bool realtime, bool download);
    void syncNow();          // automatic: timer, coming back to the app
    void syncFromButton();   // the Export page button: failures are shown in a dialog
    void testKey(QString apiUrl, QString token);

    // Fired by qsoModel.
    void qsoInserted(int id);
    void qsoEdited(int id);
    void qsoAboutToBeDeleted(int id);

signals:
    void busyChanged();
    void statusChanged();
    void syncFinished(QString summary);
    void syncFailed(QString error);
    void keyTestResult(bool ok, QString message);

private:
    enum Phase { Idle, Deletes, Upload, Download };

    adifTools adif;
    qsoModel *model;
    QNetworkAccessManager *manager;
    QTimer timer;

    QString vendorToken;
    QString apiUrl;
    QString token;
    bool active = false;
    bool realtime = true;
    bool download = true;

    bool running = false;
    bool rerun = false;
    bool rerunDownload = false;
    bool runDownload = false;
    bool manualRun = false;
    bool rerunManual = false;
    QString downloadQuery;
    QString lastStatus;

    // The run in progress.
    QString startedAt;
    int lastUploadedId = 0;
    QList<int> batchIds;
    QJsonArray batchPayload;
    QStringList batchDeleteIds;
    int sent = 0, rejected = 0, deleted = 0, merged = 0;
    int inserted = 0, updated = 0, linked = 0, removed = 0, skipped = 0;
    QStringList errors;

    void ensureSchema();
    QString state(const QString &name) const;
    void setState(const QString &name, const QString &value);
    QString tokenHash(const QString &t) const;
    bool canSync() const;

    void startRun(bool withDownload, bool manual = false);
    void stepDeletes();
    void stepUpload();
    void stepDownload(const QByteArray &next);
    void finishRun(const QString &fatal = QString());

    QNetworkRequest request(const QString &path, const QString &query = QString(),
                            const QString &url = QString(), const QString &key = QString()) const;
    bool tokenRefused(QNetworkReply *rep, const QJsonObject &body);
    void refuseToken();

    QJsonObject qsoPayload(QSqlQuery &row);
    void setQsoState(int id, const QString &status, const QString &qsoId = QString(),
                     const QString &reason = QString());
    void applyRecord(QJsonObject record);
    int matchLocal(const QVariantMap &cols, const QString &band);
};

#endif // DXQSOMANAGER_H
