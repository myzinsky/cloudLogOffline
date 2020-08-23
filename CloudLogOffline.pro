QT += quick
QT += sql
QT += svg
QT += xml
QT += gui-private
QTPLUGIN += qsvg

CONFIG += c++11

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += main.cpp
SOURCES += tools.cpp
SOURCES += translationmanager.cpp
SOURCES += cloudlogmanager.cpp
SOURCES += qrzmanager.cpp
SOURCES += rigmanager.cpp
SOURCES += dbmanager.cpp
SOURCES += qsomodel.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

ios {
    #QMAKE_INFO_PLIST = ios/Info.plist
    app_launch_images.files = $$PWD/ios/myLaunchScreen.xib
    QMAKE_BUNDLE_DATA += app_launch_images
    ios_translation.files = $$files($$PWD/translations/*.qm)
    QMAKE_BUNDLE_DATA += ios_translation
    QMAKE_ASSET_CATALOGS += ios/Media.xcassets
    QMAKE_TARGET_BUNDLE_PREFIX = de.webappjung
    #QMAKE_DEVELOPMENT_TEAM = XXXX
    #QMAKE_PROVISIONING_PROFILE = XXXXX
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
}

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += cloudlogmanager.h
HEADERS += tools.h
HEADERS += translationmanager.h
HEADERS += dbmanager.h
HEADERS += qrzmanager.h
HEADERS += qsomodel.h
HEADERS += rigmanager.h

DISTFILES += android/AndroidManifest.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew \
    android/gradlew.bat \
    android/res/values/libs.xml
DISTFILES += ios/MyLaunchScreen.xib
DISTFILES += ios/info.plist

# Translations:
TRANSLATIONS += translations/English.ts
TRANSLATIONS += translations/German.ts
android: include(/Users/myzinsky/Library/Android/sdk/android_openssl/openssl.pri)
