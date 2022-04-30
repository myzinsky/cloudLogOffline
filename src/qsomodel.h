#ifndef QSOMODEL_H
#define QSOMODEL_H
#include <QString>
#include <QAbstractListModel>
#include <QDebug>
#include <QSqlTableModel>
#include <QSqlRecord>
#include <QSqlError>

#include "dbmanager.h"

class qsoModel : public QSqlTableModel
{
    Q_OBJECT

public:
    qsoModel(QObject *parent = nullptr);
    ~qsoModel();
    QVariant data(const QModelIndex &item, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

public slots:
    void deleteQSO(int id);

    void addQSO(QString call,
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
                QString satn,
                QString satm
                );

    void updateQSO(int id,
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
                QString satn,
                QString satm
                );

    bool checkCall(QString call);

    unsigned int numberOfQSOs();

signals:
    void updateNumberOfQSOs(int number);

protected:
    QString selectStatement() const override;
};

#endif // QSOMODEL_H
