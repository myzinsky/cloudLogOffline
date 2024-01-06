cmake_minimum_required(VERSION 3.21.1)

project(CloudLogOffline VERSION 1.1.6 LANGUAGES CXX)

find_package(Qt6 REQUIRED COMPONENTS Quick)
find_package(Qt6 REQUIRED COMPONENTS Svg)
find_package(Qt6 REQUIRED COMPONENTS Sql)
find_package(Qt6 REQUIRED COMPONENTS Xml)
#find_package(Qt6 REQUIRED COMPONENTS GuiPrivate)
find_package(Qt6 REQUIRED COMPONENTS Gui)
find_package(Qt6 REQUIRED COMPONENTS Positioning)
find_package(Qt6 REQUIRED COMPONENTS Location)
find_package(Qt6 REQUIRED COMPONENTS Widgets)
find_package(Qt6 REQUIRED COMPONENTS Core)

qt_standard_project_setup()

configure_file ("${PROJECT_SOURCE_DIR}/src/version.h.in" "${PROJECT_BINARY_DIR}/src/version.h")

set(CMAKE_AUTORCC ON)

set(sources
    qml.qrc
    src/main.cpp
    src/tools.cpp
    src/translationmanager.cpp
    src/cloudlogmanager.cpp
    src/qrzmanager.cpp
    src/rigmanager.cpp
    src/dbmanager.cpp
    src/qsomodel.cpp
    src/repeatermodel.cpp
    src/sharemanager.cpp
    src/logtools.cpp
    src/adiftools.cpp
    src/cabrillotools.cpp
    src/csvtools.cpp
    src/migrationmanager.cpp
)

if (WIN32)
    set(app_icon_resource_windows "${PROJECT_SOURCE_DIR}/resources/photosurface.rc")
    qt_add_executable(CloudLogOffline ${sources} ${app_icon_resource_windows})
elseif (APPLE)
    set(MACOSX_BUNDLE_ICON_FILE logo.icns)
    set(app_icon_macos "${PROJECT_SOURCE_DIR}/images/macos/logo.icns")
    set_source_files_properties(${app_icon_macos} PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")

    qt_add_executable(CloudLogOffline MACOSX_BUNDLE
        ${sources}
        ${app_icon_macos}
    )
    set_target_properties(CloudLogOffline PROPERTIES MACOSX_BUNDLE_INFO_PLIST macos/Info.plist)
elseif (IOS)
    qt_add_executable(CloudLogOffline
        ${sources}
    )
    # Hier hab ich aufgegeben... zu kompliziert ... bleibe erstmal bei qmake
    #set_target_properties(CloudLogOffline PROPERTIES IOS_BUNDLE_INFO_PLIST ios/Info.plist)
    #set_target_properties(CloudLogOffline PROPERTIES  QT_IOS_LAUNCH_SCREEN "${PROJECT_SOURCE_DIR}/ios/myLaunchScreen.xib")
else()
    qt_add_executable(CloudLogOffline
        ${sources}
    )
endif()

qt_add_qml_module(CloudLogOffline
    URI CloudLogOffline
    VERSION 1.1.6
    QML_FILES
        qml/Main.qml
        qml/QSOView.qml
        qml/QSOListView.qml
        qml/DrawerItem.qml
        qml/PageDrawer.qml
        qml/SettingsView.qml
        qml/QSOItem.qml
        qml/QSOTextField.qml
        qml/AboutView.qml
        qml/SettingsSwitch.qml
        qml/QRZView.qml
        qml/ExportView.qml
        qml/IconButton.qml
        qml/ExportHeader.qml
        qml/DatePicker.qml
        qml/TimePicker.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(CloudLogOffline PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER de.webappjung.ClougLogOffline
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(CloudLogOffline
    PRIVATE Qt6::Quick
    PRIVATE Qt6::Sql
    PRIVATE Qt6::Svg
    PRIVATE Qt6::Xml
    PRIVATE Qt6::Gui
    PRIVATE Qt6::Positioning
    PRIVATE Qt6::Location
    PRIVATE Qt6::Widgets
    PRIVATE Qt6::Core
)

target_include_directories(CloudLogOffline
    PRIVATE "${PROJECT_BINARY_DIR}/src"
    PRIVATE "${PROJECT_SOURCE_DIR}/src"
)

include(GNUInstallDirs)

install(TARGETS CloudLogOffline
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
