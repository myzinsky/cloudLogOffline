#ifndef QRZMANAGER_H
#define QRZMANAGER_H
#include <QObject>

class qrzManager : public QObject
{
    Q_OBJECT
public:
    qrzManager(QObject *parent = 0);
    bool receiveKey();

public slots:
    bool lookupCall(QString call);

private:
    QString key;
};

#endif // QRZMANAGER_H
