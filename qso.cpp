#include "qso.h"
#include <QDebug>

qsoTest::qsoTest(QObject *parent) : QObject(parent)
{
}

void qsoTest::someSlot()
{
    qDebug() << "Slot Triggered";
}

