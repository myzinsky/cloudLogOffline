#ifndef QSOMODEL_H
#define QSOMODEL_H
#include <QString>
#include <QAbstractListModel>
#include <QDebug>

class qso {
    QString call;
    QString name;
    QString ctry;
    QString date;
    QString time;
    QString freq;
    QString mode;
    QString sent;
    QString recv;

public:
    qso(const QString &c,
        const QString &n,
        const QString &y,
        const QString &d,
        const QString &t,
        const QString &f,
        const QString &m,
        const QString &s,
        const QString &r) : call(c),
                            name(n),
                            ctry(y),
                            date(d),
                            time(t),
                            freq(f),
                            mode(m),
                            sent(s),
                            recv(r) {
    }

    QString getCall() const;
    QString getDate() const;
    QString getName() const;
    QString getCtry() const;
    QString getTime() const;
    QString getSent() const;
    QString getRecv() const;
    QString getFreq() const;
    QString getMode() const;

    void setCall(const QString &value);
    void setName(const QString &value);
    void setCtry(const QString &value);
    void setDate(const QString &value);
    void setTime(const QString &value);
    void setSent(const QString &value);
    void setRecv(const QString &value);
    void setFreq(const QString &value);
    void setMode(const QString &value);
};

class qsoModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum QSORoles {
        callRole = Qt::UserRole + 1,
        nameRole,
        ctryRole,
        dateRole,
        timeRole,
        freqRole,
        modeRole,
        sentRole,
        recvRole
    };

public:
    qsoModel(QObject *parent = 0);

    void addQSO(const qso &q);

    int rowCount(const QModelIndex & parent = QModelIndex()) const;

    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

public slots:
    void deleteQSO(int id);

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    QList<qso> qsos;
};

#endif // QSOMODEL_H
