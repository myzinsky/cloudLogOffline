#include "qsomodel.h"

qsoModel::qsoModel(QObject *parent) : QSqlTableModel(parent)
{
    setTable("qsos");
    setEditStrategy(QSqlTableModel::OnFieldChange);
    select();
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
    removeRow(id);
    endRemoveRows();
    submit();
}

void qsoModel::addQSO(QString call,
                      QString name,
                      QString ctry,
                      QString date,
                      QString time,
                      QString freq,
                      QString mode,
                      QString sent,
                      QString recv)
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

    insertRecord(rowCount(), newRecord);
    submit();
    select();
}

QHash<int, QByteArray> qsoModel::roleNames() const
{
   QHash<int, QByteArray> roles;
   for (int i = 0; i < this->record().count(); i ++) {
       roles.insert(Qt::UserRole + i + 1, record().fieldName(i).toUtf8());
   }
   return roles;
}
