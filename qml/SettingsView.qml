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

        settings.contestActive = contestSwitch.checked;
        settings.contestNumber = contestNumber.text
        settings.fixedNumber   = fixedNumberSwitch.checked;

        settings.cloudLogURL      = cloudLogURL.text;
        settings.cloudLogSSL      = cloudLogSSL.currentText;
        settings.cloudLogSSLIndex = cloudLogSSL.currentIndex
        settings.cloudLogKey      = cloudLogKey.text;
        settings.cloudLogActive   = cloudLogSwitch.checked;

        settings.qrzUser   = qrzUser.text;
        settings.qrzPass   = qrzPass.text;
        settings.qrzActive = qrzSwitch.checked;

        settings.rigHost   = rigHost.text;
        settings.rigPort   = rigPort.text;
        settings.rigActive = rigSwitch.checked;

        settings.mySotaReference = mySotaReference.text
        settings.sotaActive      = sotaSwitch.checked;

        settings.satActive = satSwitch.checked;

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
        contentWidth: -1

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
                    text: qsTr("General Settings")
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
                onEditingFinished: saveSettings();
                font.capitalization: Font.AllUppercase
            }

            Label {
                id: languageLabel
                text: qsTr("Language") + ":"
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
                    console.log("Language Changed:" + language.currentText)
                    saveSettings();
                }
            }

            SettingsSwitch {
                id: cqSwitch
                icon: "\uf519"
                text: qsTr("CQ Frequency")
                helpText: qsTr("With 'CQ Frequency' you can define a QRG which will be prefilled in the 'Live QSO' view. This mode is beneficial if you cannot connect to FlRig.")
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
                onEditingFinished: saveSettings();
            }

            // ----------------

            SettingsSwitch {
                id: contestSwitch
                icon: "\uf091"
                text: qsTr("Contest Mode")
                helpText: qsTr("In contest mode, a receive and a sent field will show up. A counting up number can be configured in the settings. A status indicator will show if a callsing is already existing in the log.");
                Layout.columnSpan: 2
                checked: settings.contestActive
            }

            Label {
                id: contestNumberLabel
                text: qsTr("Number / Province") + ":"
                visible: contestSwitch.checked
            }

            RowLayout {
                visible: contestSwitch.checked
                TextField {
                    id: contestNumber
                    Layout.fillWidth: true
                    text: settings.contestNumber
                    onTextEdited: saveSettings()
                    onEditingFinished: saveSettings();
                }

                Label {
                    text: qsTr("Fixed Number") +":";
                }

                Switch {
                    id: fixedNumberSwitch
                    checked: settings.fixedNumber
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    onToggled: saveSettings()
                }
            }

            // ----------------

            SettingsSwitch {
                id: cloudLogSwitch
                icon: "\uf0c2"
                text: qsTr("Cloud Log API")
                helpText: qsTr("Please specify the URL to Clouglog without https:// or http:// (e.g. log.cloud.com) and the specific key.")
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
                id: sslLabel
                text: qsTr("Encryption") + ":"
                visible: cloudLogSwitch.checked
            }

            ComboBox {
                id: cloudLogSSL
                Layout.fillWidth: true
                model: [
                    "http",
                    "https"
                ]

                Component.onCompleted: {
                    currentIndex = settings.cloudLogSSLIndex
                }

                onActivated: {
                    saveSettings();
                }
                visible: cloudLogSwitch.checked
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
                onEditingFinished: saveSettings();
            }

            // ----------------

            SettingsSwitch {
                id: qrzSwitch
                icon: "\uf7a2"
                text: qsTr("QRZ.com API Synchronization")
                helpText: qsTr("For QRZ.com XML Subscriber. CloudLogOffline will query QRZ.com if an internet connection is available.")
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
                onEditingFinished: saveSettings();
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
                onEditingFinished: saveSettings();
            }

            // ----------------

            SettingsSwitch {
                id: rigSwitch
                icon: "\uf6ff"
                text: qsTr("FlRig Connection")
                helpText: qsTr("Connect to Flrig by W1HKJ which e.g. runs on a Raspberry Pi which is connected to the radio and opens a Wifi to interact with CloudLogOffline")
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
                onEditingFinished: saveSettings();
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
                onEditingFinished: saveSettings();
            }

            // ----------------

            SettingsSwitch {
                id: sotaSwitch
                icon: "\uf6fc"
                text: qsTr("Summits on the Air (SOTA)")
                helpText: qsTr("Insert here youre SOTA reference")
                Layout.columnSpan: 2
                checked: settings.sotaActive
            }

            Label {
                id: mySotaLabel
                text: qsTr("Reference") + ":"
                visible: sotaSwitch.checked
            }

            TextField {
                id: mySotaReference
                Layout.fillWidth: true
                visible: sotaSwitch.checked
                text: settings.mySotaReference
                onTextEdited: saveSettings();
                onEditingFinished: saveSettings();
                font.capitalization: Font.AllUppercase
                inputMethodHints: Qt.ImhUppercaseOnly
            }

            // ----------------

            SettingsSwitch {
                id: satSwitch
                icon: "\uf7bf"
                text: qsTr("Satellite")
                helpText: qsTr("Enable satellites fields in QSO View")
                Layout.columnSpan: 2
                checked: settings.satActive
            }
        }
    }
}
