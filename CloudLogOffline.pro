QT += quick
QT += sql
QT += svg
QT += xml
QT += gui-private
QT += positioning
QT += location
QT += core

CONFIG += c++11

GIT_VERSION = "1.1.6"
message($$GIT_VERSION)
DEFINES += GIT_VERSION=\\\"$$GIT_VERSION\\\"

DEFINES += QT_DEPRECATED_WARNINGS

SOURCES += src/main.cpp
SOURCES += src/tools.cpp
SOURCES += src/translationmanager.cpp
SOURCES += src/cloudlogmanager.cpp
SOURCES += src/qrzmanager.cpp
SOURCES += src/rigmanager.cpp
SOURCES += src/dbmanager.cpp
SOURCES += src/qsomodel.cpp
SOURCES += src/repeatermodel.cpp
SOURCES += src/sharemanager.cpp
SOURCES += src/logtools.cpp
SOURCES += src/adiftools.cpp
SOURCES += src/cabrillotools.cpp
SOURCES += src/csvtools.cpp
SOURCES += src/migrationmanager.cpp

RESOURCES += qml.qrc
QMAKE_RESOURCE_FLAGS += -no-compress

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

ios {
    message(Build for IOS)
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
    message(Build for MacOS)
    ICON = images/macos/logo_circle.icns
    QMAKE_INFO_PLIST = macos/Info.plist
    QT += widgets
    QMAKE_BUNDLE_DATA += macos_translation
    QMAKE_TARGET_BUNDLE_PREFIX = de.webappjung

    #Enititlements:
    ENTITLEMENTS = macos/Entitlements.plist
    OTHER_FILES += macos/Entitlements.plist
}

android {
    message(Build for Android)
    ANDROID_OPENSSL_DIR = $$PWD/android_openssl
    include($$ANDROID_OPENSSL_DIR/openssl.pri)
    message($$ANDROID_OPENSSL_DIR)
    DISTFILES += android/AndroidManifest.xml \
}

!isEmpty(PREFIX) {
    target.path = $$PREFIX/bin
    INSTALLS += target
}
else: !android {
    qnx:  PREFIX = /tmp/$${TARGET}
    else: PREFIX = /opt/$${TARGET}
}

HEADERS += src/cloudlogmanager.h
HEADERS += src/tools.h
HEADERS += src/translationmanager.h
HEADERS += src/dbmanager.h
HEADERS += src/qrzmanager.h
HEADERS += src/qsomodel.h
HEADERS += src/repeatermodel.h
HEADERS += src/rigmanager.h
HEADERS += src/sharemanager.h
HEADERS += src/adiftools.h
HEADERS += src/cabrillotools.h
HEADERS += src/csvtools.h
HEADERS += src/logtools.h
HEADERS += src/migrationmanager.h

DISTFILES += android/AndroidManifest.xml
DISTFILES += qml/RepeaterItem.qml
DISTFILES += qml/RepeaterListView.qml
DISTFILES += qml/QSOViewWrapper.qml
DISTFILES += qml/TimePicker.qml

DISTFILES += ios/MyLaunchScreen.xib
DISTFILES += ios/info.plist

DISTFILES += qml/Main.qml
DISTFILES += qml/QSOView.qml
DISTFILES += qml/qtquickcontrols2.conf
DISTFILES += qml/QSOListView.qml
DISTFILES += qml/DrawerItem.qml
DISTFILES += qml/PageDrawer.qml
DISTFILES += qml/SettingsView.qml
DISTFILES += qml/QSOItem.qml
DISTFILES += qml/QSOTextField.qml
DISTFILES += qml/AboutView.qml
DISTFILES += qml/SettingsSwitch.qml
DISTFILES += qml/QRZView.qml
DISTFILES += qml/ExportView.qml
DISTFILES += qml/IconButton.qml
DISTFILES += qml/ExportHeader.qml
DISTFILES += qml/DatePicker.qml
DISTFILES += qml/TimePicker.qml

# Translations:
TRANSLATIONS += translations/English.ts
TRANSLATIONS += translations/German.ts
TRANSLATIONS += translations/Armenian.ts
