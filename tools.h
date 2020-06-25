#ifndef SYSTEM_H
#define SYSTEM_H

#include <QtGui/qpa/qplatformwindow.h>
#include <QVariantMap>
#include <QQuickWindow>

class tools : public QObject
{
    Q_OBJECT

public:
    tools();

public slots:
    QVariantMap getSafeAreaMargins(QQuickWindow *window);

};

#endif // SYSTEM_H
