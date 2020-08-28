#include <QGuiApplication>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "qsomodel.h"
#include "dbmanager.h"
#include "qrzmanager.h"
#include "rigmanager.h"
#include "cloudlogmanager.h"
#include "translationmanager.h"
#include "tools.h"
#include "shareutils.h"

#ifdef Q_OS_IOS
#include "ios/iosshareutils.h"
#endif

#ifdef Q_OS_ANDROID
#include "android/androidshareutils.h"
#endif

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);
    QQmlApplicationEngine engine;

    dbManager db;
    db.createTables();
    qrzManager qrz;
    rigManager rig;
    qsoModel qModel;
    cloudlogManager cl(&qModel);
    translationManager tm(&app, &engine);
    tools t;

    qmlRegisterType<shareUtils> ("com.lasconic", 1, 0, "ShareUtils");

    // Load the QML and set the Context:
    engine.rootContext()->setContextProperty("qsoModel", QVariant::fromValue(&qModel));
    engine.rootContext()->setContextProperty("qrz", QVariant::fromValue(&qrz));
    engine.rootContext()->setContextProperty("rig", QVariant::fromValue(&rig));
    engine.rootContext()->setContextProperty("cl", QVariant::fromValue(&cl));
    engine.rootContext()->setContextProperty("tm", QVariant::fromValue(&tm));
    engine.rootContext()->setContextProperty("tools", QVariant::fromValue(&t));

    engine.load(QUrl(QStringLiteral("qrc:/Main.qml")));

    return app.exec();
}
