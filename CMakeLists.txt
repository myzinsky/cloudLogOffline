cmake_minimum_required(VERSION 3.16...3.29)

project(CloudLogOffline VERSION 1.1.6 LANGUAGES CXX)

include(GNUInstallDirs)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)

set(minimum_qt_version "")
if(ANDROID OR IOS)
    set(minimum_qt_version "6.5")
endif()

find_package(Qt6 ${minimum_qt_version} REQUIRED COMPONENTS Gui LinguistTools Positioning Quick Sql Svg Widgets Xml)
# Qt 6.10 and later only define Qt::GuiPrivate when it is asked for by name.
if(Qt6_VERSION VERSION_GREATER_EQUAL 6.10)
    find_package(Qt6 REQUIRED COMPONENTS GuiPrivate)
endif()


add_library(LibCloudLogOffline STATIC
    src/adiftools.cpp
    src/cabrillotools.cpp
    src/cacheddata.cpp
    src/cloudlogmanager.cpp
    src/csvtools.cpp
    src/dbmanager.cpp
    src/dxqsomanager.cpp
    src/logtools.cpp
    src/maidenhead.cpp
    src/migrationmanager.cpp
    src/qrzmanager.cpp
    src/qsomodel.cpp
    src/repeatermodel.cpp
    src/rigmanager.cpp
    src/sharemanager.cpp
    src/tools.cpp
    src/translationmanager.cpp
)
# IDE convenience
file(GLOB headers "${CMAKE_CURRENT_SOURCE_DIR}/src/*.h")
target_sources(LibCloudLogOffline PRIVATE ${headers})

target_compile_definitions(LibCloudLogOffline PUBLIC GIT_VERSION="${PROJECT_VERSION}")

# DxQSO sync: the vendor token naming this app to DxQSO. Not a secret, but kept out of the
# repository: pass -DDXQSO_VENDOR_TOKEN=... when building a tester build.
set(DXQSO_VENDOR_TOKEN "" CACHE STRING "DxQSO vendor token baked into the build")
if(DXQSO_VENDOR_TOKEN)
    target_compile_definitions(LibCloudLogOffline PRIVATE DXQSO_VENDOR_TOKEN="${DXQSO_VENDOR_TOKEN}")
endif()

qt_add_resources(LibCloudLogOffline resources
    FILES
        # Qt6 qml
        qml/AboutView.qml
        qml/AppMessage.qml
        qml/DatePicker.qml
        qml/DrawerItem.qml
        qml/ExportHeader.qml
        qml/ExportView.qml
        qml/IconButton.qml
        qml/Main.qml
        qml/PageDrawer.qml
        qml/QRZView.qml
        qml/QSOItem.qml
        qml/QSOListView.qml
        qml/QSOTextField.qml
        qml/QSOView.qml
        qml/QSOViewWrapper.qml
        qml/RepeaterItem.qml
        qml/RepeaterListView.qml
        qml/SettingsSwitch.qml
        qml/SettingsView.qml
        qml/SvgImage.qml
        qml/TimePicker.qml
        # Other
        fonts/fa-solid-900.ttf
        fonts/LinLibertine_DR_G.ttf
        fonts/Roboto-Regular.ttf
        images/logo_circle.png
        images/logo_circle.svg
        images/logo_square.svg
)

qt_add_translations(LibCloudLogOffline
    TS_FILES
        translations/Armenian.ts
        translations/English.ts
        translations/German.ts
)

target_link_libraries(LibCloudLogOffline
    PUBLIC
        Qt::GuiPrivate
        Qt::Positioning
        Qt::Quick
        Qt::Sql
        Qt::Xml
    PRIVATE
        Qt::Svg
)


add_executable(CloudLogOffline WIN32 src/main.cpp)

target_link_libraries(CloudLogOffline PRIVATE LibCloudLogOffline)

if(NOT ANDROID AND NOT IOS)
    target_link_libraries(CloudLogOffline PRIVATE Qt::Widgets) # Cf. main.cpp
endif()

install(
    TARGETS CloudLogOffline
    RUNTIME DESTINATION .
    BUNDLE DESTINATION ${CMAKE_SOURCE_DIR}
)


option(BUILD_TESTING "Build tests" ON)
if(BUILD_TESTING)
    enable_testing()
    add_subdirectory(tests)
endif()

## This is required for localization permissions to work
if(QT_VERSION_MAJOR EQUAL 6)
    qt_finalize_executable(${TARGET})
endif()
