#include <QGuiApplication>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "qsomodel.h"
#include "dbmanager.h"
#include "qrzmanager.h"
#include "rigmanager.h"
#include "cloudlogmanager.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    //QGuiApplication app(argc, argv);
    QApplication app(argc, argv);

    dbManager db;
    db.createTables();
    qrzManager qrz;
    rigManager rig;
    cloudlogManager cl;

    qsoModel qModel;
    QQmlApplicationEngine engine;

    // Load the QML and set the Context:
    engine.load(QUrl(QStringLiteral("qrc:/Main.qml")));
    engine.rootContext()->setContextProperty("qsoModel", QVariant::fromValue(&qModel));
    engine.rootContext()->setContextProperty("qrz", QVariant::fromValue(&qrz));
    engine.rootContext()->setContextProperty("rig", QVariant::fromValue(&rig));
    engine.rootContext()->setContextProperty("cl", QVariant::fromValue(&cl));

    return app.exec();
}
