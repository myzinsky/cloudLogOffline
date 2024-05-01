// https://doc.qt.io/archives/qt-5.12/modules-qml.html
// https://doc.qt.io/archives/qt-5.12/qtquickcontrols-index.html
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import Qt.labs.settings 1.0
import de.webappjung 1.0

ApplicationWindow {
    id: window
    visible: true
    width: 1024
    height: 748
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

    //Screen.orientationUpdateMask: Qt.LandscapeOrientation | Qt.PortraitOrientation
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
        property string gridsquare
        property string language
        property int languageIndex

        property string cqMode
        property int cqModeIndex
        property string cqFreq
        property bool cqActive

        property bool contestActive
        property string contestNumber
        property bool fixedNumber

        property string cloudLogURL
        property string cloudLogSSL
        property int cloudLogSSLIndex
        property string cloudLogKey
        property int cloudLogStationId
        property bool cloudLogActive

        property string qrzUser
        property string qrzPass
        property bool qrzActive

        property string rigHost
        property string rigPort
        property bool rigActive

        property string mySotaReference
        property bool sotaActive

        property string myWwffReference
        property bool wwffActive

        property string myPotaReference
        property bool potaActive

        property bool satActive

        property bool rbActive
        property string rbRadius
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
            text: stackView.currentItem == null ? "?" : stackView.currentItem.title
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
                    "addQSO"      : false,
                    "liveQSO"     : true,
                    "updateQSO"   : false,
                    "repeaterQSO" : false,
                });
            }

            anchors.right: parent.right // iPhoneX workaround
            anchors.rightMargin: Math.max(notchLeft, notchRight) // iPhoneX workaround
            anchors.bottom: parent.bottom // iPhoneX workaround
        }

        ToolButton {
            id: saveButtonGlobal
            text:"\uf0c7"
            visible: stackView.currentItem == null ? false : stackView.currentItem.toString().includes("QSOViewWrapper")
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

        iconTitle: "CloudLogOffline"
        iconSource: "qrc:///images/logo_circle.svg"
        iconSubtitle: "Version " + AppInfo.version

        iconBgColorLeft: "#B0BEC5"
        iconBgColorRight: "#607D8B"

        //
        // Define the drawer items
        //
        items: ListModel {
            id: pagesModel

            ListElement { // 0
                pageTitle: qsTr ("Show Logbook")
                pageIcon: "\uf02d"
                onTriggered: function() {
                    stackView.push("QSOListView.qml")
                }
            }

            ListElement { // 1
                pageTitle: qsTr ("Add QSO")
                pageIcon: "\uf055"
                onTriggered: function() {
                    stackView.push("QSOViewWrapper.qml",
                                   {
                                       "addQSO"      : true,
                                       "liveQSO"     : false,
                                       "updateQSO"   : false,
                                       "repeaterQSO" : false,
                                   });
                }
            }

            ListElement {
                pageTitle: qsTr ("Add Live QSO")
                pageIcon: "\uf055"
                onTriggered: function() {
                    stackView.push("QSOViewWrapper.qml",
                                   {
                                       "addQSO"      : false,
                                       "liveQSO"     : true,
                                       "updateQSO"   : false,
                                       "repeaterQSO" : false,
                                   });
                }
            }

            ListElement {
                pageTitle: qsTr ("Add Repeater QSO")
                pageIcon: "\uf055"
                onTriggered: function() {
                    stackView.push("RepeaterListView.qml");
                }
            }

            ListElement {
                separator: true
            }

            ListElement {
                pageTitle: qsTr ("Export")
                pageIcon: "\uf56e"
                onTriggered: function() {
                    stackView.push("ExportView.qml")
                }
            }

            ListElement {
                pageTitle: qsTr ("Settings")
                pageIcon: "\uf013"
                onTriggered: function() {
                    stackView.push("SettingsView.qml")
                }
            }

            ListElement {
                pageTitle: qsTr ("About")
                pageIcon: "\uf05a"
                onTriggered: function() {
                    stackView.push("AboutView.qml")
                }
            }
        }
    }
    
    QSOListView {
        id: initialStackViewItem
    }

    StackView {
        id: stackView
        anchors.fill: parent
        anchors.leftMargin: notchLeft
        anchors.rightMargin: notchRight
        
        initialItem: initialStackViewItem

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
