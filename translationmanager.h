#ifndef TRANSLATIONMANAGER_H
#define TRANSLATIONMANAGER_H

#include <QObject>
#include <QTranslator>
#include <QQmlApplicationEngine>
#include <QApplication>
#include <QDebug>

class translationManager : public QObject
{
    Q_OBJECT
public:
    translationManager(QApplication *app, QQmlApplicationEngine *engine);

public slots:
    void switchToLanguage(const QString &language);

private:
    QTranslator *translator;
    QApplication *app;
    QQmlApplicationEngine *engine;
};

#endif // TRANSLATIONMANAGER_H
