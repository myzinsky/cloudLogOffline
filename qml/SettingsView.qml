import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import QtQuick.Controls.Material 2.4

Page {
    id: settingsView
    title: qsTr("Settings")
    anchors.margins: 5

    function saveSettings()
    {
        console.log("Settings Saved");

        settings.call = call.text;
        settings.gridsquare = gridsquare.text;
        settings.language = language.currentText;
        settings.languageIndex = language.currentIndex;

        settings.cqMode         = cqMode.currentText;
        settings.cqModeIndex    = cqMode.currentIndex;
        settings.cqFreq         = cqFreq.text;
        settings.cqActive       = cqSwitch.checked;

        settings.contestActive = contestSwitch.checked;
        settings.contestNumber = contestNumber.text
        settings.fixedNumber   = fixedNumberSwitch.checked;

        var clURL = cloudLogURL.text;
        if (clURL.endsWith("/")) {
            clURL = clURL.substring(0, clURL.length - 1);
        }
        if (clURL.endsWith("/index.php/api/qso")) {
            clURL = clURL.substring(0, clURL.length - 18);
        }
        if (clURL.startsWith("http://")) {
            clURL = clURL.substring(7, clURL.length);
        }
        if (clURL.startsWith("https://")) {
            clURL = clURL.substring(8, clURL.length);
        }
        settings.cloudLogURL       = clURL;
        settings.cloudLogSSL       = cloudLogSSL.currentText;
        settings.cloudLogSSLIndex  = cloudLogSSL.currentIndex;
        settings.cloudLogKey       = cloudLogKey.text;
        settings.cloudLogStationId = cloudLogStationId.value;
        settings.cloudLogActive    = cloudLogSwitch.checked;

        settings.qrzUser   = qrzUser.text;
        settings.qrzPass   = qrzPass.text;
        settings.qrzActive = qrzSwitch.checked;

        settings.rigHost   = rigHost.text;
        settings.rigPort   = rigPort.text;
        settings.rigActive = rigSwitch.checked;

        settings.mySotaReference = mySotaReference.text
        settings.sotaActive      = sotaSwitch.checked;

        settings.myWwffReference = myWwffReference.text
        settings.wwffActive      = wwffSwitch.checked;

        settings.myPotaReference = myPotaReference.text
        settings.potaActive      = potaSwitch.checked;

        settings.satActive = satSwitch.checked;

        settings.rbActive = rbSwitch.checked;
        settings.rbRadius = rbRadius.text;

        // Retrieve new key when settings changed:
        if(settings.qrzUser.length !== 0 &&
                settings.qrzPass.length !== 0 &&
                settings.qrzActive) {
            console.log("Receive Key")
            qrz.receiveKey()
        }
    }

    function apiKeyOk() {
        cloudLogApiKeyTestButton.highlighted = true
        cloudLogApiKeyTestButton.Material.theme = Material.Light
        cloudLogApiKeyTestButton.Material.accent = Material.Green
    }

    function apiKeyRo() {
        cloudLogApiKeyTestButton.highlighted = true
        cloudLogApiKeyTestButton.Material.theme = Material.Light
        cloudLogApiKeyTestButton.Material.accent = Material.Orange
    }

    function apiKeyInvalid()
    {
        cloudLogApiKeyTestButton.highlighted = true
        cloudLogApiKeyTestButton.Material.theme = Material.Light
        cloudLogApiKeyTestButton.Material.accent = Material.Red
    }

    Connections{
        target: rb
        onLocatorDone: function(locator) {
            console.log("LOCATOR DONE");
            gridsquare.text = locator;
            saveSettings();
            rb.stopPositioning();
        }
    }

    Connections{
        target: cl
        function onApiKeyOk() {
            apiKeyOk();
        }

        function onApiKeyRo() {
            apiKeyRo();
        }

        function onApiKeyInvalid() {
            apiKeyInvalid();
        }
    }

    ScrollView {
        id: settingsScrollView
        anchors.fill: parent
        contentWidth: -1
        contentHeight: grid.height

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
                id: gridsquareLabel
                text: qsTr("Locator") + ":"
            }

            GridLayout {
                id: locatorgrid
                columns: 2

                TextField {
                    id: gridsquare
                    Layout.fillWidth: true
                    text: settings.gridsquare
                    onTextEdited: saveSettings()
                    onEditingFinished: saveSettings();
                    font.capitalization: Font.AllUppercase
                }

                Button {
                    text : qsTr("Lookup")
                    onClicked: {
                        rb.tryStartPositioning(gridsquare.text)
                    }
                }
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
                    "German",
                    "Armenian"
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

            // ----------------

            SettingsSwitch {
                id: cqSwitch
                icon: "\uf519"
                text: qsTr("CQ Mode / Frequency")
                helpText: qsTr("With 'CQ Mode / Frequency' you can define a mode and QRG which will be prefilled in the 'Live QSO' view. This mode is beneficial if you cannot connect to FlRig.")
                Layout.columnSpan: 2
                checked: settings.cqActive
            }

            Label {
                id: cqModeLabel
                text: qsTr("Mode") + ":"
                visible: cqSwitch.checked
            }

            ComboBox {
                id: cqMode
                Layout.fillWidth: true
                visible: cqSwitch.checked
                model: [
                    "SSB",
                    "SSB / LSB",
                    "SSB / USB",
                    "FM",
                    "AM",
                    "CW",
                    "DSTAR",
                    "C4FM",
                    "DMR",
                    "DIGITALVOICE",
                    "PSK31",
                    "PSK63",
                    "RTTY",
                    "JT65",
                    "JT65B",
                    "JT6C",
                    "JT9-1",
                    "JT9",
                    "FT4",
                    "FT8",
                    "JS8",
                    "FSK441",
                    "JTMS",
                    "ISCAT",
                    "MSK144",
                    "JTMSK",
                    "QRA64",
                    "PKT",
                    "SSTV",
                    "HELL",
                    "HELL80",
                    "MFSK16",
                    "JT6M",
                    "ROS",
                ]
                Component.onCompleted: {
                    currentIndex = settings.cqModeIndex
                }
                onActivated: {
                    saveSettings();
                }
            }

            Label {
                id: cqFreqLabel
                text: qsTr("QRG [MHz]") + ":"
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
                helpText: qsTr("Please specify the Hostname to Clouglog without https:// or http:// (e.g. log.cloud.com) and the specific API key. The station ID is optional for Cloudlog v1 and mandatory for v2. You can find the IDs in the \"Station Locations\" section inside your profile of your Cloudlog instance.")
                Layout.columnSpan: 2
                checked: settings.cloudLogActive
            }

            Label {
                id: cloudLogURLLabel
                text: qsTr("Hostname") + ":"
                visible: cloudLogSwitch.checked
            }

            TextField {
                id: cloudLogURL
                Layout.fillWidth: true
                visible: cloudLogSwitch.checked
                text: settings.cloudLogURL
                onEditingFinished: saveSettings()
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
                    "HTTP",
                    "HTTPS"
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
                text: qsTr("API Key") + ":"
                visible: cloudLogSwitch.checked
            }

            GridLayout {
                id: apiKey
                visible: cloudLogSwitch.checked
                columns: 2

                TextField {
                    id: cloudLogKey
                    Layout.fillWidth: true
                    visible: cloudLogSwitch.checked
                    text: settings.cloudLogKey
                    echoMode: TextInput.Password
                    onTextEdited: saveSettings()
                    onEditingFinished: saveSettings();
                }

                Button {
                    id: cloudLogApiKeyTestButton
                    text : qsTr("Test API Key")
                    visible: cloudLogSwitch.checked

                    onClicked: {
                        cl.testApiKey(settings.cloudLogSSL, settings.cloudLogURL, cloudLogKey.text);
                    }
                }
            }

            Label {
                id: cloudLogStationIdLabel
                text: qsTr("Station ID") + ":"
                visible: cloudLogSwitch.checked
            }

            SpinBox {
                id: cloudLogStationId
                visible: cloudLogSwitch.checked
                from: 1
                to: 999
                editable: true
                value: settings.cloudLogStationId
                onValueModified: saveSettings();
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
                helpText: qsTr("Insert here your SOTA reference")
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
                id: wwffSwitch
                icon: "\uf1bb"
                text: qsTr("World Wide Flora & Fauna (WWFF)")
                helpText: qsTr("Insert here your WWFF reference")
                Layout.columnSpan: 2
                checked: settings.wwffActive
            }

            Label {
                id: myWWFFLabel
                text: qsTr("Reference") + ":"
                visible: wwffSwitch.checked
            }

            TextField {
                id: myWwffReference
                Layout.fillWidth: true
                visible: wwffSwitch.checked
                text: settings.myWwffReference
                onTextEdited: saveSettings();
                onEditingFinished: saveSettings();
                font.capitalization: Font.AllUppercase
                inputMethodHints: Qt.ImhUppercaseOnly
            }
            // ----------------

            SettingsSwitch {
                id: potaSwitch
                icon: "\uf540"
                text: qsTr("Parks on the Air")
                helpText: qsTr("Insert here your POTA reference")
                Layout.columnSpan: 2
                checked: settings.potaActive
            }

            Label {
                id: myPotaLabel
                text: qsTr("Reference") + ":"
                visible: potaSwitch.checked
            }

            TextField {
                id: myPotaReference
                Layout.fillWidth: true
                visible: potaSwitch.checked
                text: settings.myPotaReference
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
                helpText: qsTr("Enable satellite fields in QSO View")
                Layout.columnSpan: 2
                checked: settings.satActive
            }

            // ----------------

            SettingsSwitch {
                id: rbSwitch
                icon: "\uf519"
                text: qsTr("Hear HAM Repeater List")
                helpText: qsTr("Activate this to see repeaters near to you")
                Layout.columnSpan: 2
                checked: settings.rbActive
            }

            Label {
                text: qsTr("Radius") + ":"
                visible: rbSwitch.checked
            }

            TextField {
                id: rbRadius
                Layout.fillWidth: true
                visible: rbSwitch.checked
                text: settings.rbRadius
                onTextEdited: saveSettings();
                onEditingFinished: saveSettings();
                font.capitalization: Font.AllUppercase
                inputMethodHints: Qt.ImhUppercaseOnly
            }
        }
    }
}
