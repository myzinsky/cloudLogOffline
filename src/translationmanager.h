#ifndef TRANSLATIONMANAGER_H
#define TRANSLATIONMANAGER_H

#include <QObject>
#include <QTranslator>
#include <QQmlApplicationEngine>
#include <QCoreApplication>
#include <QDebug>

class translationManager : public QObject
{
    Q_OBJECT
public:
    translationManager(QCoreApplication *app, QQmlApplicationEngine *engine);

public slots:
    void switchToLanguage(const QString &language);

private:
    QTranslator *translator;
    QCoreApplication *app;
    QQmlApplicationEngine *engine;
};

#endif // TRANSLATIONMANAGER_H
