#include "qsomodel.h"

void qso::setName(const QString &value)
{
    name = value;
}

void qso::setCall(const QString &value)
{
    call = value;
}

QString qso::getName() const
{
    return name;
}

QString qso::getCtry() const
{
    return ctry;
}

void qso::setCtry(const QString &value)
{
    ctry = value;
}

void qso::setDate(const QString &value)
{
    date = value;
}

QString qso::getTime() const
{
    return time;
}

void qso::setTime(const QString &value)
{
    time = value;
}

QString qso::getSent() const
{
    return sent;
}

void qso::setSent(const QString &value)
{
    sent = value;
}

QString qso::getRecv() const
{
    return recv;
}

void qso::setRecv(const QString &value)
{
    recv = value;
}

QString qso::getFreq() const
{
    return freq;
}

void qso::setFreq(const QString &value)
{
    freq = value;
}

QString qso::getMode() const
{
    return mode;
}

void qso::setMode(const QString &value)
{
    mode = value;
}

QString qso::getCall() const
{
    return call;
}

QString qso::getDate() const
{
    return date;
}

qsoModel::qsoModel(QObject *parent) : QAbstractListModel(parent)
{
}

void qsoModel::addQSO(const qso &q)
{
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    qsos.push_front(q);
    endInsertRows();
}

int qsoModel::rowCount(const QModelIndex & parent) const {
    Q_UNUSED(parent);
    return qsos.count();
}

QVariant qsoModel::data(const QModelIndex & index, int role) const {
    if (index.row() < 0 || index.row() >= qsos.count())
        return QVariant();

    const qso &q = qsos[index.row()];

    switch (role) {
        case callRole: return q.getCall(); break;
        case nameRole: return q.getName(); break;
        case ctryRole: return q.getCtry(); break;
        case dateRole: return q.getDate(); break;
        case timeRole: return q.getTime(); break;
        case freqRole: return q.getFreq(); break;
        case modeRole: return q.getMode(); break;
        case sentRole: return q.getSent(); break;
        case recvRole: return q.getRecv(); break;
    }

    return QVariant();
}

QHash<int, QByteArray> qsoModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[callRole]  = "call";
    roles[nameRole]  = "name";
    roles[ctryRole]  = "ctry";
    roles[dateRole]  = "date";
    roles[timeRole]  = "time";
    roles[freqRole]  = "freq";
    roles[modeRole]  = "mode";
    roles[sentRole]  = "sent";
    roles[recvRole]  = "recv";

    return roles;
}

