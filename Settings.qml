import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.2


Page {
    id: settingsView
    title: qsTr("Settings")
    anchors.fill: parent
    anchors.margins: 5

    ScrollView {
        anchors.fill: parent

        ListView {
            model: settingsModel
            delegate: ItemDelegate {
                GridLayout {
                    id: grid
                    width: settingsView.width // Important
                    columns: 2

                    SettingsSwitch {
                        id: cqSwitch
                        icon: "\uf519"
                        text: "CQ Frequency"
                        Layout.columnSpan: 2
                    }

                    Label {
                        id: cqFreqLabel
                        text: "Frequency:"
                        visible: cqSwitch.checked
                    }

                    TextField {
                        id: cqFreq
                        Layout.fillWidth: true
                        visible: cqSwitch.checked
                        text: settingsModel.cqFreq
                    }

                    // ----------------

                    SettingsSwitch {
                        id: cloudLogSwitch
                        icon: "\uf0c2"
                        text: "Cloud Log API"
                        Layout.columnSpan: 2
                    }

                    Label {
                        id: cloudLogURLLabel
                        text: "URL:"
                        visible: cloudLogSwitch.checked
                    }

                    TextField {
                        id: cloudLogURL
                        Layout.fillWidth: true
                        visible: cloudLogSwitch.checked
                    }

                    Label {
                        id: cloudLogKeyLabel
                        text: "Key:"
                        visible: cloudLogSwitch.checked
                    }

                    TextField {
                        id: cloudlogKey
                        Layout.fillWidth: true
                        visible: cloudLogSwitch.checked
                    }

                    // ----------------

                    SettingsSwitch {
                        id: qrzSwitch
                        icon: "\uf7a2"
                        text: "QRZ.com API Synchronization"
                        Layout.columnSpan: 2
                    }

                    Label {
                        id: qrzUserLabel
                        text: "Username:"
                        visible: qrzSwitch.checked
                    }

                    TextField {
                        id: qrzUser
                        Layout.fillWidth: true
                        visible: qrzSwitch.checked
                    }

                    Label {
                        id: qrzPassLabel
                        text: "Password:"
                        visible: qrzSwitch.checked
                    }

                    TextField {
                        id: qrzPass
                        Layout.fillWidth: true
                        visible: qrzSwitch.checked
                        echoMode: TextInput.Password
                    }

                    // ----------------

                    SettingsSwitch {
                        id: rigSwitch
                        icon: "\uf6ff"
                        text: "FlRig Connection"
                        Layout.columnSpan: 2
                    }

                    Label {
                        id: rigHostLabel
                        text: "Hostname:"
                        visible: rigSwitch.checked
                    }

                    TextField {
                        id: rigHost
                        Layout.fillWidth: true
                        visible: rigSwitch.checked
                    }

                    Label {
                        id: rigPortLabel
                        text: "Port:"
                        visible: rigSwitch.checked
                    }

                    TextField {
                        id: rigPort
                        Layout.fillWidth: true
                        visible: rigSwitch.checked
                    }

                }
            }
        }
    }
}
