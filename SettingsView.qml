import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import QtQuick.Controls.Material 2.4

Page {
    id: settingsView
    title: qsTr("Settings")
    anchors.fill: parent
    anchors.margins: 5

    function saveSettings()
    {
        console.log("Settings Saved");

        settings.call = call.text;
        settings.language = language.currentText;
        settings.languageIndex = language.currentIndex;

        settings.cqFreq   = cqFreq.text;
        settings.cqActive = cqSwitch.checked;

        settings.cloudLogURL    = cloudLogURL.text;
        settings.cloudLogKey    = cloudLogKey.text;
        settings.cloudLogActive = cloudLogSwitch.checked;

        settings.qrzUser   = qrzUser.text;
        settings.qrzPass   = qrzPass.text;
        settings.qrzActive = qrzSwitch.checked;

        settings.rigHost   = rigHost.text;
        settings.rigPort   = rigPort.text;
        settings.rigActive = rigSwitch.checked;

        // Retrieve new key when settings changed:
        if(settings.qrzUser.length !== 0 &&
                settings.qrzPass.length !== 0 &&
                settings.qrzActive) {
            console.log("Receive Key")
            qrz.receiveKey()
        }
    }

    ScrollView {
        id: settingsScrollView
        anchors.fill: parent
        GridLayout {
            id: grid
            width: settingsView.width // Important
            columns: 2

            Rectangle {
                height: 48
                color: "#555555"
                Layout.fillWidth: true
                Layout.columnSpan: 2

                Label {
                    id: settingsIcon
                    text: "\uf013"
                    font.family: fontAwesome.name
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    font.pixelSize: Qt.application.font.pixelSize * 1.6
                    opacity: 0.87
                    anchors.verticalCenter: parent.verticalCenter
                }

                Label {
                    id: settingsText
                    text: "General Settings"
                    anchors.left: settingsIcon.right
                    anchors.leftMargin: 5
                    font.pixelSize: 14
                    opacity: 0.87
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Label {
                id: callLabel
                text: qsTr("Your Call") + ":"
            }

            TextField {
                id: call
                Layout.fillWidth: true
                text: settings.call
                onTextEdited: saveSettings()
                font.capitalization: Font.AllUppercase
            }

            Label {
                id: languageLabel
                text: qsTr("Language")
            }

            ComboBox {
                id: language
                Layout.fillWidth: true
                model: [
                    "English",
                    "German"
                ]

                Component.onCompleted: {
                    currentIndex = settings.languageIndex
                }

                onActivated: {
                    tm.switchToLanguage(language.currentText);
                    saveSettings();
                }
            }

            SettingsSwitch {
                id: cqSwitch
                icon: "\uf519"
                text: qsTr("CQ Frequency")
                Layout.columnSpan: 2
                checked: settings.cqActive
            }

            Label {
                id: cqFreqLabel
                text: qsTr("Frequency") + ":"
                visible: cqSwitch.checked
            }

            TextField {
                id: cqFreq
                Layout.fillWidth: true
                visible: cqSwitch.checked
                text: settings.cqFreq
                onTextEdited: saveSettings()
            }

            // ----------------

            SettingsSwitch {
                id: cloudLogSwitch
                icon: "\uf0c2"
                text: qsTr("Cloud Log API")
                Layout.columnSpan: 2
                checked: settings.cloudLogActive
            }

            Label {
                id: cloudLogURLLabel
                text: qsTr("URL") + ":"
                visible: cloudLogSwitch.checked
            }

            TextField {
                id: cloudLogURL
                Layout.fillWidth: true
                visible: cloudLogSwitch.checked
                text: settings.cloudLogURL
                onTextEdited: saveSettings()
            }

            Label {
                id: cloudLogKeyLabel
                text: qsTr("Key") + ":"
                visible: cloudLogSwitch.checked
            }

            TextField {
                id: cloudLogKey
                Layout.fillWidth: true
                visible: cloudLogSwitch.checked
                text: settings.cloudLogKey
                echoMode: TextInput.Password
                onTextEdited: saveSettings()
            }

            // ----------------

            SettingsSwitch {
                id: qrzSwitch
                icon: "\uf7a2"
                text: qsTr("QRZ.com API Synchronization")
                Layout.columnSpan: 2
                checked: settings.qrzActive
            }

            Label {
                id: qrzUserLabel
                text: qsTr("Username") + ":"
                visible: qrzSwitch.checked
            }

            TextField {
                id: qrzUser
                Layout.fillWidth: true
                visible: qrzSwitch.checked
                text: settings.qrzUser
                onTextEdited: saveSettings();
            }

            Label {
                id: qrzPassLabel
                text: qsTr("Password") + ":"
                visible: qrzSwitch.checked
            }

            TextField {
                id: qrzPass
                Layout.fillWidth: true
                visible: qrzSwitch.checked
                echoMode: TextInput.Password
                text: settings.qrzPass
                onTextEdited: saveSettings();
            }

            // ----------------

            SettingsSwitch {
                id: rigSwitch
                icon: "\uf6ff"
                text: qsTr("FlRig Connection")
                Layout.columnSpan: 2
                checked: settings.rigActive
            }

            Label {
                id: rigHostLabel
                text: qsTr("Hostname") + ":"
                visible: rigSwitch.checked
            }

            TextField {
                id: rigHost
                Layout.fillWidth: true
                visible: rigSwitch.checked
                text: settings.rigHost
                onTextEdited: saveSettings();
            }

            Label {
                id: rigPortLabel
                text: qsTr("Port") + ":"
                visible: rigSwitch.checked
            }

            TextField {
                id: rigPort
                Layout.fillWidth: true
                visible: rigSwitch.checked
                text: settings.rigPort
                onTextEdited: saveSettings();
            }
        }
    }
}
