QT += quick
QT += sql
QT += svg
QT += xml
QT += gui-private
QTPLUGIN += qsvg

CONFIG += c++11

# Get Verison number from Tag:
#GIT_VERSION = $$system(git --git-dir $$PWD/.git --work-tree $$PWD describe --always --tags)
#GIT_VERSION ~= s/-/"."
#GIT_VERSION ~= s/g/""
#GIT_VERSION ~= s/\.\d+\.[a-f0-9]{6,}//
GIT_VERSION = "1.0.4"
message($$GIT_VERSION)
DEFINES += GIT_VERSION=\\\"$$GIT_VERSION\\\"

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += src/main.cpp
SOURCES += src/tools.cpp
SOURCES += src/translationmanager.cpp
SOURCES += src/cloudlogmanager.cpp
SOURCES += src/qrzmanager.cpp
SOURCES += src/rigmanager.cpp
SOURCES += src/dbmanager.cpp
SOURCES += src/qsomodel.cpp
SOURCES += src/shareutils.cpp
SOURCES += src/logtools.cpp
SOURCES += src/adiftools.cpp
SOURCES += src/cabrillotools.cpp
SOURCES += src/csvtools.cpp
SOURCES += src/migrationmanager.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

ios {
    OBJECTIVE_SOURCES += ios/iosshareutils.mm
    HEADERS += ios/iosshareutils.h

    #QMAKE_INFO_PLIST = ios/Info.plist
    app_launch_images.files = $$PWD/ios/myLaunchScreen.xib
    QMAKE_BUNDLE_DATA += app_launch_images
    ios_translation.files = $$files($$PWD/translations/*.qm)
    QMAKE_BUNDLE_DATA += ios_translation
    QMAKE_ASSET_CATALOGS += ios/Media.xcassets
    QMAKE_TARGET_BUNDLE_PREFIX = de.webappjung

    Q_ENABLE_BITCODE.name = ENABLE_BITCODE
    Q_ENABLE_BITCODE.value = NO
    QMAKE_MAC_XCODE_SETTINGS += Q_ENABLE_BITCODE
}

macx {
    ICON = images/macos/logo_circle.icns
    QMAKE_INFO_PLIST = macos/Info.plist
    QT += widgets
    macos_translation.files = $$files($$PWD/translations/*.qm)
    macos_translation.path = "Contents/MacOS"
    QMAKE_BUNDLE_DATA += macos_translation
    QMAKE_TARGET_BUNDLE_PREFIX = de.webappjung
}

android {
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
    include(/Users/myzinsky/Library/Android/sdk/android_openssl/openssl.pri) # TODO make generic path
    QT += androidextras
    android_translation.files = $$files($$PWD/translations/*.qm)
    android_translation.path = /assets
    INSTALLS += android_translation
    OTHER_FILES += android/src/com/lasconic/QShareUtils.java
    HEADERS += android/androidshareutils.h
    SOURCES += android/androidshareutils.cpp
}

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += src/cloudlogmanager.h
HEADERS += src/tools.h
HEADERS += src/translationmanager.h
HEADERS += src/dbmanager.h
HEADERS += src/qrzmanager.h
HEADERS += src/qsomodel.h
HEADERS += src/rigmanager.h
HEADERS += src/shareutils.h
HEADERS += src/adiftools.h
HEADERS += src/cabrillotools.h
HEADERS += src/csvtools.h
HEADERS += src/logtools.h
HEADERS += src/migrationmanager.h

DISTFILES += android/AndroidManifest.xml \
    qml/TimePicker.qml
DISTFILES += android/build.gradle
DISTFILES += android/gradle/wrapper/gradle-wrapper.jar
DISTFILES += android/gradle/wrapper/gradle-wrapper.properties
DISTFILES += android/gradlew
DISTFILES += android/gradlew.bat
DISTFILES += android/res/values/libs.xml

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

android: include(/Users/myzinsky/Library/Android/sdk/android_openssl/openssl.pri)

ANDROID_ABIS = armeabi-v7a arm64-v8a
