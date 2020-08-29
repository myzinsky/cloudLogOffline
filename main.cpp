#include <QGuiApplication>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFontDatabase>

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

    // Work around for Oneplus Android devices = load an embedded font file and use it..
    // https://bugreports.qt.io/browse/QTBUG-69494
#ifdef Q_OS_ANDROID
    QFont font = QGuiApplication::font();
    QFontDatabase fdb;
    int id = QFontDatabase::addApplicationFont(":/fonts/Roboto-Regular.ttf");
    QString family = QFontDatabase::applicationFontFamilies(id).at(0);
    font.setFamily(family);
    QGuiApplication::setFont(font);
#endif

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
