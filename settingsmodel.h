#ifndef SETTINGSMODEL_H
#define SETTINGSMODEL_H
#include <QSqlTableModel>
#include <QSqlRecord>

class settingsModel : public QSqlTableModel
{
public:
    settingsModel();
    ~settingsModel();
    QVariant data(const QModelIndex &item, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

public slots:
    void updateSettings();
};

#endif // SETTINGSMODEL_H
