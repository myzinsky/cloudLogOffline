#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "qso.h"
#include "qsomodel.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    qsoTest q;
    qsoModel model;

    model.addQSO(qso("DL9MJ", "Matthias", "Germany", "17.06.2020", "18:00", "14.200 MHz", "SSB", "59", "59+20"));
    model.addQSO(qso("DL0XK", "TU Kaiserslautern", "Germany", "17.06.2020", "18:00", "14.200 MHz", "SSB", "59", "59+20"));

    QQmlApplicationEngine engine;

    // Load the QML and set the Context:
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    engine.rootContext()->setContextProperty("qso", &q);
    engine.rootContext()->setContextProperty("qsoModel", QVariant::fromValue(&model));

    return app.exec();
}
