GIT_VERSION = "1.1.6"
message("*** Configuring CloudLogOffline $$GIT_VERSION for $$QMAKE_PLATFORM ***")
DEFINES += GIT_VERSION=\\\"$$GIT_VERSION\\\"

android|ios: QT_MINIMUM_REQUIRED = 6.5.0
else:        QT_MINIMUM_REQUIRED = 5.12.0
!versionAtLeast(QT_VERSION, $$QT_MINIMUM_REQUIRED) {
    error("CloudLogOffline needs Qt $$QT_MINIMUM_REQUIRED or newer (found: $${QT_VERSION})")
}

QT += quick
QT += sql
QT += svg
QT += xml
QT += gui-private
QT += positioning
QT += core

# cf. main.cpp
!android:!ios: QT += widgets

CONFIG += c++11

DEFINES += QT_DEPRECATED_WARNINGS

SOURCES += src/adiftools.cpp
SOURCES += src/cabrillotools.cpp
SOURCES += src/cloudlogmanager.cpp
SOURCES += src/csvtools.cpp
SOURCES += src/dbmanager.cpp
SOURCES += src/logtools.cpp
SOURCES += src/main.cpp
SOURCES += src/migrationmanager.cpp
SOURCES += src/qrzmanager.cpp
SOURCES += src/qsomodel.cpp
SOURCES += src/repeatermodel.cpp
SOURCES += src/rigmanager.cpp
SOURCES += src/sharemanager.cpp
SOURCES += src/tools.cpp
SOURCES += src/translationmanager.cpp

QMAKE_RESOURCE_FLAGS += -no-compress
RESOURCES += common.qrc
!versionAtLeast(QT_VERSION, 6.0.0) {
    RESOURCES += qt5/qml.qrc
    QML_IMPORT_PATH = qt5/qml
}
else {
    CONFIG += qtquickcompiler
    RESOURCES += qml.qrc
    QML_IMPORT_PATH = qml
}

ios {
    QMAKE_INFO_PLIST = ios/Info.plist
    app_launch_images.files = $$PWD/ios/myLaunchScreen.xib
    QMAKE_BUNDLE_DATA += app_launch_images
    QMAKE_ASSET_CATALOGS += ios/Media.xcassets
    QMAKE_TARGET_BUNDLE_PREFIX = de.webappjung

    Q_ENABLE_BITCODE.name = ENABLE_BITCODE
    Q_ENABLE_BITCODE.value = NO
    QMAKE_MAC_XCODE_SETTINGS += Q_ENABLE_BITCODE
}

macx {
    ICON = images/macos/logo_circle.icns
    QMAKE_INFO_PLIST = macos/Info.plist
    QMAKE_BUNDLE_DATA += macos_translation
    QMAKE_TARGET_BUNDLE_PREFIX = de.webappjung

    ENTITLEMENTS = macos/Entitlements.plist
    OTHER_FILES += macos/Entitlements.plist
}

android {
    ANDROID_OPENSSL_DIR = $$PWD/android_openssl
    include($$ANDROID_OPENSSL_DIR/openssl.pri)
    message("Using $$ANDROID_OPENSSL_DIR")
}

# Default rules for deployment.
!isEmpty(PREFIX):    target.path = $$PREFIX/bin
else: qnx:           target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += src/adiftools.h
HEADERS += src/cabrillotools.h
HEADERS += src/cloudlogmanager.h
HEADERS += src/csvtools.h
HEADERS += src/dbmanager.h
HEADERS += src/logtools.h
HEADERS += src/migrationmanager.h
HEADERS += src/qrzmanager.h
HEADERS += src/qsomodel.h
HEADERS += src/repeatermodel.h
HEADERS += src/rigmanager.h
HEADERS += src/sharemanager.h
HEADERS += src/tools.h
HEADERS += src/translationmanager.h

DISTFILES += android/AndroidManifest.xml

DISTFILES += ios/myLaunchScreen.xib
DISTFILES += ios/Info.plist

DISTFILES += qtquickcontrols2.conf

DISTFILES += qml/AboutView.qml
DISTFILES += qml/DatePicker.qml
DISTFILES += qml/DrawerItem.qml
DISTFILES += qml/ExportHeader.qml
DISTFILES += qml/ExportView.qml
DISTFILES += qml/IconButton.qml
DISTFILES += qml/Main.qml
DISTFILES += qml/PageDrawer.qml
DISTFILES += qml/QRZView.qml
DISTFILES += qml/QSOItem.qml
DISTFILES += qml/QSOListView.qml
DISTFILES += qml/QSOTextField.qml
DISTFILES += qml/QSOView.qml
DISTFILES += qml/QSOViewWrapper.qml
DISTFILES += qml/RepeaterItem.qml
DISTFILES += qml/RepeaterListView.qml
DISTFILES += qml/SettingsSwitch.qml
DISTFILES += qml/SettingsView.qml
DISTFILES += qml/TimePicker.qml

DISTFILES += qt5/qml/AboutView.qml
DISTFILES += qt5/qml/DatePicker.qml
DISTFILES += qt5/qml/DrawerItem.qml
DISTFILES += qt5/qml/ExportHeader.qml
DISTFILES += qt5/qml/ExportView.qml
DISTFILES += qt5/qml/IconButton.qml
DISTFILES += qt5/qml/Main.qml
DISTFILES += qt5/qml/PageDrawer.qml
DISTFILES += qt5/qml/QRZView.qml
DISTFILES += qt5/qml/QSOItem.qml
DISTFILES += qt5/qml/QSOListView.qml
DISTFILES += qt5/qml/QSOTextField.qml
DISTFILES += qt5/qml/QSOView.qml
DISTFILES += qt5/qml/QSOViewWrapper.qml
DISTFILES += qt5/qml/RepeaterItem.qml
DISTFILES += qt5/qml/RepeaterListView.qml
DISTFILES += qt5/qml/SettingsSwitch.qml
DISTFILES += qt5/qml/SettingsView.qml
DISTFILES += qt5/qml/TimePicker.qml

CONFIG += lrelease embed_translations

TRANSLATIONS += translations/Armenian.ts
TRANSLATIONS += translations/English.ts
TRANSLATIONS += translations/German.ts
