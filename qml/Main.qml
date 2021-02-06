import QtQuick 2.12
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.4
import Qt.labs.settings 1.0
import QtQuick.Window 2.12
import de.webappjung 1.0

ApplicationWindow {
    id: window
    visible: true
    width: 640
    height: 480
    title: qsTr("CloudLogOffline Logbook")

    // Full screen iPhone X workaround:
    property int safeWidth
    property int notchTop
    property int notchLeft
    property int notchRight
    flags: Qt.platform.os === "ios"? Qt.Window | Qt.MaximizeUsingFullscreenGeometryHint : Qt.Window

    Timer {
        id: oriTimer
        interval: 100; running: true; repeat: false
        onTriggered: {
            console.log("Orientatino Changed")
            console.log("safe margins =", JSON.stringify(tools.getSafeAreaMargins(window)))
            notchTop   = tools.getSafeAreaMargins(window)["top"]
            notchLeft  = tools.getSafeAreaMargins(window)["left"]
            notchRight = tools.getSafeAreaMargins(window)["right"]
            safeWidth  = window.width - tools.getSafeAreaMargins(window)["left"] - tools.getSafeAreaMargins(window)["right"]
        }
    }

    Screen.orientationUpdateMask: Qt.LandscapeOrientation | Qt.PortraitOrientation
    Screen.onPrimaryOrientationChanged: {
        oriTimer.start()
    }

    Component.onCompleted:  {
        tm.switchToLanguage(settings.language)
        notchTop = tools.getSafeAreaMargins(window)["top"] // iPhoneX workaround

        console.log("load settings.language:" + settings.language)
        console.log("safe margins =", JSON.stringify(tools.getSafeAreaMargins(window)))
    }

    // Android Back Button Fix:
    onClosing: {
        if (Qt.platform.os == "android" && stackView.depth > 1){
            close.accepted = false
            stackView.pop();
        } else {
            return;
        }
    }

    // Stores the settings even after restart:
    Settings {
        id: settings

        property string call
        property string language
        property int languageIndex

        property string cqFreq
        property bool cqActive

        property bool contestActive
        property string contestNumber
        property bool fixedNumber

        property string cloudLogURL
        property string cloudLogSSL
        property int cloudLogSSLIndex
        property string cloudLogKey
        property bool cloudLogActive

        property string qrzUser
        property string qrzPass
        property bool qrzActive

        property string rigHost
        property string rigPort
        property bool rigActive

        property string mySotaReference
        property bool sotaActive

        property bool satActive
    }

    Material.theme: Material.Dark
    Material.accent: Material.BlueGrey

    FontLoader {
        id: fontAwesome
        source: "qrc:///fonts/fa-solid-900.ttf"
        Component.onCompleted: console.log(name)
    }

    header: ToolBar {
        contentHeight: toolButton.implicitHeight + notchTop // iPhone X Workaround

        Material.primary: Material.BlueGrey

        ToolButton {
            id: toolButton
            text: stackView.depth > 1 ? "\uf053" : "\uf0c9"
            font.family: fontAwesome.name
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            onClicked: {
                if (stackView.depth > 1) {
                    stackView.pop()
                    drawer.index = -1
                } else {
                    drawer.open()
                }
            }
            anchors.left: parent.left // iPhoneX workaround
            anchors.leftMargin: Math.max(notchLeft, notchRight) // iPhoneX workaround
            anchors.bottom: parent.bottom // iPhoneX workaround
        }

        Label {
            text: stackView.currentItem.title
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: toolButton.verticalCenter
        }

        ToolButton {
            id: plusButton
            text:"\uf055"
            visible: (stackView.depth == 1)
            font.family: fontAwesome.name
            font.pixelSize: Qt.application.font.pixelSize * 1.6

            onClicked: {
                stackView.push("QSOViewWrapper.qml",
                {
                    "addQSO"    : false,
                    "liveQSO"   : true,
                    "updateQSO" : false,
                    "ctss"      : settings.contestActive ? settings.contestNumber : "",
                });
            }

            anchors.right: parent.right // iPhoneX workaround
            anchors.rightMargin: Math.max(notchLeft, notchRight) // iPhoneX workaround
            anchors.bottom: parent.bottom // iPhoneX workaround
        }

        ToolButton {
            id: saveButton
            text:"\uf0c7"
            visible: (stackView.currentItem.toString().includes("QSOViewWrapper"))
            font.family: fontAwesome.name
            font.pixelSize: Qt.application.font.pixelSize * 1.6

            onClicked: {
                stackView.currentItem.save();
            }

            anchors.right: parent.right // iPhoneX workaround
            anchors.rightMargin: Math.max(notchLeft, notchRight) // iPhoneX workaround
            anchors.bottom: parent.bottom // iPhoneX workaround
        }
    }

    PageDrawer {
        id: drawer

        iconTitle: "CloudLog Offline"
        iconSource: "qrc:///images/logo_circle.svg"
        iconSubtitle: "Version " + AppInfo.version

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
                stackView.push("QSOViewWrapper.qml",
                       {
                           "addQSO"    : true,
                           "liveQSO"   : false,
                           "updateQSO" : false,
                       });
            },
            2: function() {
                stackView.push("QSOViewWrapper.qml",
                       {
                           "addQSO"    : false,
                           "liveQSO"   : true,
                           "updateQSO" : false,
                           "ctss"      : settings.contestActive ? settings.contestNumber : "",
                       });
            },
            5: function() {
                stackView.push("ExportView.qml");
            },
            6: function() {
                stackView.push("SettingsView.qml")
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
                spacer: true
            }

            ListElement { // 4
                separator: true
            }

            ListElement { // 5
                pageTitle: qsTr ("Export")
                pageIcon: "\uf56e"
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
        anchors.leftMargin: notchLeft
        anchors.rightMargin: notchRight

        pushEnter: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 0
                to:1
                duration: 200
            }
        }
        pushExit: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 1
                to:0
                duration: 200
            }
        }
        popEnter: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 0
                to:1
                duration: 200
            }
        }
        popExit: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 1
                to:0
                duration: 200
            }
        }
    }
}
