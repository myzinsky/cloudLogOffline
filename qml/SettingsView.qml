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
        settings.cloudLogStationId = cloudLogStationId.text;
        settings.cloudLogActive    = cloudLogSwitch.checked;

        settings.dxqsoActive   = dxqsoSwitch.checked;
        settings.dxqsoToken    = dxqsoToken.text.trim();
        settings.dxqsoApiUrl   = dxqsoApiUrl.text.trim();
        settings.dxqsoRealtime = dxqsoRealtime.checked;
        settings.dxqsoDownload = dxqsoDownload.checked;
        dx.configure(settings.dxqsoApiUrl, settings.dxqsoToken, settings.dxqsoActive,
                     settings.dxqsoRealtime, settings.dxqsoDownload);

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

    Connections{
        target: dx
        function onKeyTestResult(ok, message) {
            dxqsoKeyTestButton.highlighted = true
            dxqsoKeyTestButton.Material.theme = Material.Light
            dxqsoKeyTestButton.Material.accent = ok ? Material.Green : Material.Red
            dxqsoKeyInfo.text = message
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
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            TextField {
                id: call
                Layout.fillWidth: true
                text: settings.call
                onTextEdited: saveSettings()
                onEditingFinished: saveSettings();
                font.capitalization: Font.AllUppercase
                Layout.rightMargin: 10
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            }

            Label {
                id: gridsquareLabel
                text: qsTr("Locator") + ":"
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            GridLayout {
                id: locatorgrid
                columns: 2

                Layout.rightMargin: 10
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

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
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            ComboBox {
                id: language
                Layout.fillWidth: true

                Layout.rightMargin: 10
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

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
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            ComboBox {
                id: cqMode
                Layout.fillWidth: true
                visible: cqSwitch.checked

                Layout.rightMargin: 10
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

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
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            TextField {
                id: cqFreq
                Layout.fillWidth: true
                visible: cqSwitch.checked

                Layout.rightMargin: 10
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

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
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            RowLayout {
                visible: contestSwitch.checked

                Layout.rightMargin: 10
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

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
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            TextField {
                id: cloudLogURL
                Layout.fillWidth: true
                visible: cloudLogSwitch.checked
                text: settings.cloudLogURL
                onEditingFinished: saveSettings()
                Layout.rightMargin: 10
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            }

            Label {
                id: sslLabel
                text: qsTr("Encryption") + ":"
                visible: cloudLogSwitch.checked
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            ComboBox {
                id: cloudLogSSL
                Layout.fillWidth: true

                Layout.rightMargin: 10
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                model: [
                    "HTTPS",
                    "HTTP"
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
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            GridLayout {
                id: apiKey
                visible: cloudLogSwitch.checked
                columns: 2

                Layout.rightMargin: 10
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

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
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            TextField {
                id: cloudLogStationId
                Layout.fillWidth: true
                visible: cloudLogSwitch.checked
                text: settings.cloudLogStationId
                onTextEdited: saveSettings()
                onEditingFinished: saveSettings()

                Layout.rightMargin: 10
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            }

            // ----------------

            SettingsSwitch {
                id: dxqsoSwitch
                icon: "\uf021"
                text: qsTr("DxQSO Sync")
                helpText: qsTr("Two-way sync with DxQSO (dxqso.org). Paste a station token (or an account key) from the Stations page on dxqso.net. QSOs logged here go to that DxQSO Station, and QSOs added, edited or deleted on DxQSO come back here. Deleting a QSO here deletes it on DxQSO too; Delete All QSOs on the Export page only clears this device.")
                Layout.columnSpan: 2
                checked: settings.dxqsoActive
            }

            Label {
                text: qsTr("Key") + ":"
                visible: dxqsoSwitch.checked
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            GridLayout {
                visible: dxqsoSwitch.checked
                columns: 2
                Layout.rightMargin: 10
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                TextField {
                    id: dxqsoToken
                    Layout.fillWidth: true
                    text: settings.dxqsoToken
                    echoMode: TextInput.Password
                    onEditingFinished: saveSettings()
                    onTextEdited: dxqsoKeyInfo.text = dx.describeKey(text)
                }

                Button {
                    id: dxqsoKeyTestButton
                    text : qsTr("Test Key")
                    onClicked: {
                        dx.testKey(dxqsoApiUrl.text, dxqsoToken.text);
                    }
                }
            }

            Label {
                id: dxqsoKeyInfo
                visible: dxqsoSwitch.checked && text.length > 0
                text: dx.describeKey(settings.dxqsoToken)
                wrapMode: Text.WordWrap
                opacity: 0.7
                Layout.columnSpan: 2
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
            }

            Label {
                text: qsTr("Send each QSO when saved") + ":"
                visible: dxqsoSwitch.checked
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            Switch {
                id: dxqsoRealtime
                visible: dxqsoSwitch.checked
                checked: settings.dxqsoRealtime
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                onToggled: saveSettings()
            }

            Label {
                text: qsTr("Download from DxQSO") + ":"
                visible: dxqsoSwitch.checked
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            Switch {
                id: dxqsoDownload
                visible: dxqsoSwitch.checked
                checked: settings.dxqsoDownload
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                onToggled: saveSettings()
            }

            Label {
                text: qsTr("Server") + ":"
                visible: dxqsoSwitch.checked
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            TextField {
                id: dxqsoApiUrl
                Layout.fillWidth: true
                visible: dxqsoSwitch.checked
                text: settings.dxqsoApiUrl
                placeholderText: "https://api.dxqso.net"
                onEditingFinished: saveSettings()
                Layout.rightMargin: 10
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
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
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            TextField {
                id: qrzUser
                Layout.fillWidth: true
                visible: qrzSwitch.checked
                text: settings.qrzUser
                onTextEdited: saveSettings();
                onEditingFinished: saveSettings();

                Layout.rightMargin: 10
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            }

            Label {
                id: qrzPassLabel
                text: qsTr("Password") + ":"
                visible: qrzSwitch.checked
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            TextField {
                id: qrzPass
                Layout.fillWidth: true
                visible: qrzSwitch.checked
                echoMode: TextInput.Password
                text: settings.qrzPass
                onTextEdited: saveSettings();
                onEditingFinished: saveSettings();

                Layout.rightMargin: 10
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
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
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            TextField {
                id: rigHost
                Layout.fillWidth: true
                visible: rigSwitch.checked
                text: settings.rigHost
                onTextEdited: saveSettings();
                onEditingFinished: saveSettings();

                Layout.rightMargin: 10
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            }

            Label {
                id: rigPortLabel
                text: qsTr("Port") + ":"
                visible: rigSwitch.checked
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            TextField {
                id: rigPort
                Layout.fillWidth: true
                visible: rigSwitch.checked
                text: settings.rigPort
                onTextEdited: saveSettings();
                onEditingFinished: saveSettings();

                Layout.rightMargin: 10
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
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
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
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

                Layout.rightMargin: 10
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
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
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
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

                Layout.rightMargin: 10
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
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
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
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

                Layout.rightMargin: 10
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
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
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
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

                Layout.rightMargin: 10
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            }
        }
    }
}
