#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFontDatabase>

#ifdef QT_WIDGETS_LIB
#include <QApplication>
#endif

#include "qsomodel.h"
#include "repeatermodel.h"
#include "dbmanager.h"
#include "migrationmanager.h"
#include "qrzmanager.h"
#include "rigmanager.h"
#include "cloudlogmanager.h"
#include "translationmanager.h"
#include "tools.h"
#include "sharemanager.h"

int main(int argc, char *argv[])
{
    /**
     * QApplication is required for Widgets.
     * 
     * QML MessageDialog from Qt Labs Platform (Qt.labs.platform) needs Widgets if !android:!ios.
     * QML MessageDialog from Qt Quick Dialog (QtQuick.Dialogs) needs Qt 6.3 but not Widgets.
     * However, the Quick fallback dialog is ugly and cuts off large content.
     */
#ifdef QT_WIDGETS_LIB
#if QT_VERSION < QT_VERSION_CHECK(6,0,0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    qputenv("QT_FILE_SELECTORS", "qt5");
#endif
    QApplication app(argc, argv);
#else
    QGuiApplication app(argc, argv);
#endif
    app.setOrganizationName("webappjung");
    app.setOrganizationDomain("de.webappjung");

#if QT_VERSION < QT_VERSION_CHECK(6,0,0)
#  define QT_VERSION_SUFFIX " (Qt 5)"
#else
#  define QT_VERSION_SUFFIX ""
#endif
    app.setApplicationVersion(GIT_VERSION QT_VERSION_SUFFIX);

    QQmlApplicationEngine engine;

    dbManager db;
    db.createTables();
    migrationManager mm;
    qrzManager qrz;
    rigManager rig;
    qsoModel qModel;
    rbManager rb;
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

    qmlRegisterType<shareManager> ("de.webappjung", 1, 0, "ShareUtils");

    // Load the QML and set the Context:
    engine.rootContext()->setContextProperty("qsoModel", QVariant::fromValue(&qModel));
    engine.rootContext()->setContextProperty("rb", QVariant::fromValue(&rb));
    engine.rootContext()->setContextProperty("qrz", QVariant::fromValue(&qrz));
    engine.rootContext()->setContextProperty("rig", QVariant::fromValue(&rig));
    engine.rootContext()->setContextProperty("cl", QVariant::fromValue(&cl));
    engine.rootContext()->setContextProperty("tm", QVariant::fromValue(&tm));
    engine.rootContext()->setContextProperty("tools", QVariant::fromValue(&t));
    engine.rootContext()->setContextProperty("database", QVariant::fromValue(&mm));

    engine.load(QUrl(QStringLiteral("qrc:/qml/Main.qml")));

    return app.exec();
}
