#ifndef QSO_H
#define QSO_H
#include <QObject>

class qsoTest : public QObject
{
    Q_OBJECT
public:
    explicit qsoTest(QObject *parent = 0);

public slots:
    void someSlot();
};

#endif // QSO_H
