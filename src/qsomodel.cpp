#include "qsomodel.h"

qsoModel::qsoModel(QObject *parent) : QSqlTableModel(parent)
{
    setTable("qsos");
    setEditStrategy(QSqlTableModel::OnFieldChange);
    select();
}

qsoModel::~qsoModel()
{
    submitAll();
}

QVariant qsoModel::data(const QModelIndex &index, int role) const
{
    QVariant value;

    if (index.isValid()) {
        if (role < Qt::UserRole) {
            value = QSqlQueryModel::data(index, role);
        } else {
            int columnIdx = role - Qt::UserRole - 1;
            QModelIndex modelIndex = this->index(index.row(), columnIdx);
            value = QSqlQueryModel::data(modelIndex, Qt::DisplayRole);
        }
    }
    return value;
}

void qsoModel::deleteQSO(int id) {
    beginRemoveRows(QModelIndex(), id, id);
    removeRows(id, 1 ,QModelIndex());
    endRemoveRows();
    submit();

    emit updateNumberOfQSOs(numberOfQSOs());
}

void qsoModel::addQSO(QString call,
                      QString name,
                      QString ctry,
                      QString date,
                      QString time,
                      QString freq,
                      QString mode,
                      QString sent,
                      QString recv,
                      QString grid,
                      QString qqth,
                      QString comm,
                      QString ctss,
                      QString ctsr,
                      QString sota,
                      QString sots,
                      QString wwff,
                      QString wwfs,
                      QString pota,
                      QString pots,
                      QString satn,
                      QString satm,
                      QString propmode,
                      QString rxfreq,
                      QString loca
                      )
{
    QSqlRecord newRecord = record();

    newRecord.setValue("call", call);
    newRecord.setValue("name", name);
    newRecord.setValue("ctry", ctry);
    newRecord.setValue("date", date);
    newRecord.setValue("time", time);
    newRecord.setValue("freq", freq);
    newRecord.setValue("mode", mode);
    newRecord.setValue("sent", sent);
    newRecord.setValue("recv", recv);
    newRecord.setValue("grid", grid);
    newRecord.setValue("qqth", qqth);
    newRecord.setValue("comm", comm);
    newRecord.setValue("ctss", ctss);
    newRecord.setValue("ctsr", ctsr);
    newRecord.setValue("sota", sota);
    newRecord.setValue("sots", sots); // MY_SOTA
    newRecord.setValue("wwff", wwff);
    newRecord.setValue("wwfs", wwfs); // MY_WWFF
    newRecord.setValue("pota", pota);
    newRecord.setValue("pots", pots); // MY_POTA
    newRecord.setValue("satn", satn);
    newRecord.setValue("satm", satm);
    newRecord.setValue("propmode", propmode);
    newRecord.setValue("rxfreq", rxfreq);
    newRecord.setValue("loca", loca); // MY_GRIDSQUARE

    newRecord.setValue("sync", 0);

    insertRecord(rowCount(), newRecord);
    submit();
    select();

    emit updateNumberOfQSOs(numberOfQSOs());
}

void qsoModel::updateQSO(int id,
                         QString call,
                         QString name,
                         QString ctry,
                         QString date,
                         QString time,
                         QString freq,
                         QString mode,
                         QString sent,
                         QString recv,
                         QString grid,
                         QString qqth,
                         QString comm,
                         QString ctss,
                         QString ctsr,
                         QString sota,
                         QString sots,
                         QString wwff,
                         QString wwfs,
                         QString pota,
                         QString pots,
                         QString satn,
                         QString satm,
                         QString propmode,
                         QString rxfreq,
                         QString loca
                         )
{
    qDebug() << "UPDATE QSO" << id;
    QSqlRecord r = record(id);

    r.setValue("call", call);
    r.setValue("name", name);
    r.setValue("ctry", ctry);
    r.setValue("date", date);
    r.setValue("time", time);
    r.setValue("freq", freq);
    r.setValue("mode", mode);
    r.setValue("sent", sent);
    r.setValue("recv", recv);
    r.setValue("grid", grid);
    r.setValue("qqth", qqth);
    r.setValue("comm", comm);
    r.setValue("ctss", ctss);
    r.setValue("ctsr", ctsr);
    r.setValue("sota", sota);
    r.setValue("sots", sots); // MY_SOTA
    r.setValue("wwff", wwff);
    r.setValue("wwfs", wwfs); // MY_WWFF
    r.setValue("pota", pota);
    r.setValue("pots", pots); // MY_POTA
    r.setValue("satn", satn);
    r.setValue("satm", satm);
    r.setValue("propmode", propmode);
    r.setValue("rxfreq", rxfreq);
    r.setValue("loca", loca); // MY_GRIDSQUARE

    setRecord(id, r);
    submit();
    select();
}

bool qsoModel::checkCall(QString call)
{
    QSqlQuery query;
    query.prepare("SELECT COUNT(*) FROM qsos WHERE call = '"+call+"';");

    if(!query.exec()) {
        qDebug() << "SQL Error:" << query.lastError().text();
    }

    query.next();
    int number =  query.value(0).toInt();
    return number >= 1;
}

unsigned int qsoModel::numberOfQSOs()
{
    QSqlQuery query;
    query.prepare("SELECT COUNT(*) FROM qsos;");

    if(!query.exec()) {
        qDebug() << "SQL Error:" << query.lastError().text();
    }

    query.next();
    return query.value(0).toInt();
}

QString qsoModel::selectStatement() const
{
    // https://stackoverflow.com/questions/45600944/display-first-few-rows-using-qtsql-qsqltablemodel-with-qtableview
    QString query = QSqlTableModel::selectStatement();
    query += QString(" ORDER BY strftime('%Y-%m-%d %H:%M', substr(date,7,4)||\"-\"||substr(date,4,2)||\"-\"||substr(date,1,2)||\" \"||time) DESC");
    return query;
}

QHash<int, QByteArray> qsoModel::roleNames() const
{
   QHash<int, QByteArray> roles;
   for (int i = 0; i < this->record().count(); i ++) {
       roles.insert(Qt::UserRole + i + 1, record().fieldName(i).toUtf8());
   }
   return roles;
}
