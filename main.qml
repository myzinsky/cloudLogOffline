import QtQuick 2.12
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.4



ApplicationWindow {
    id: window
    visible: true
    width: 640
    height: 480
    title: qsTr("CloudLog Offline Logbook")

    Material.theme: Material.Dark
    Material.accent: Material.BlueGrey

    FontLoader {
        id: fontAwesome
        source: "qrc:///fonts/fa-solid-900.ttf"
    }

    header: ToolBar {
        contentHeight: toolButton.implicitHeight

        Material.primary: Material.BlueGrey

        ToolButton {
            id: toolButton
            text: stackView.depth > 1 ? "\uf053" : "\uf0c9"
            font.family: fontAwesome.name
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            onClicked: {
                if (stackView.depth > 1) {
                    stackView.pop()
                } else {
                    drawer.open()
                }
            }
        }

        Label {
            text: stackView.currentItem.title
            anchors.centerIn: parent
        }
    }

    PageDrawer {
        id: drawer

        iconTitle: "CloudLog Offline"
        iconSource: "qrc:///images/logo_circle.svg"
        iconSubtitle: qsTr ("Version 0.1 Alpha")

        iconBgColorLeft: "#B0BEC5"
        iconBgColorRight: "#607D8B"

        //
        // Define the actions to take for each drawer item
        // Drawers 5 and 6 are ignored, because they are used for
        // displaying a spacer and a separator
        //
        actions: {
            0: function() {
                stackView.push("QSOListView.qml")
            },
            1: function() {
                stackView.push("QSOView.qml",
                               {
                                   "addQSO"    : true,
                                   "liveQSO"   : false,
                                   "updateQSO" : false,
                               });
            },
            2: function() {
                stackView.push("QSOView.qml",
                               {
                                   "addQSO"    : false,
                                   "liveQSO"   : true,
                                   "updateQSO" : false,
                               });
            },
            6: function() {
                stackView.push("Settings.qml")
            },
            7: function() {
                stackView.push("AboutView.qml")
            }
        }

        //
        // Define the drawer items
        //
        items: ListModel {
            id: pagesModel

            ListElement { // 0
                pageTitle: qsTr ("Show Logbook")
                pageIcon: "\uf02d"
            }

            ListElement { // 1
                pageTitle: qsTr ("Add QSO")
                pageIcon: "\uf055"
            }

            ListElement { // 2
                pageTitle: qsTr ("Add Live QSO")
                pageIcon: "\uf055"
            }

            ListElement { // 3
                pageTitle: qsTr ("Start Contest")
                pageIcon: "\uf091"
            }

            ListElement { // 4
                spacer: true
            }

            ListElement { // 5
                separator: true
            }

            ListElement { // 6
                pageTitle: qsTr ("Settings")
                pageIcon: "\uf013"
            }

            ListElement { // 7
                pageTitle: qsTr ("About")
                pageIcon: "\uf05a"
            }
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
    }
}


