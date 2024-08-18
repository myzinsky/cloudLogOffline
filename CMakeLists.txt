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


add_library(LibCloudLogOffline STATIC
    src/adiftools.cpp
    src/cabrillotools.cpp
    src/cloudlogmanager.cpp
    src/csvtools.cpp
    src/dbmanager.cpp
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

qt_add_resources(LibCloudLogOffline resources
    FILES
        # Qt6 qml
        qml/AboutView.qml
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

install(TARGETS CloudLogOffline)


option(BUILD_TESTING "Build tests" ON)
if(BUILD_TESTING)
    enable_testing()
    add_subdirectory(tests)
endif()
