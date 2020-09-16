import QtQuick 2.2
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls.Material 2.4
import Qt.labs.settings 1.0

Page {
    id: page
    anchors.fill: parent
    title: (addQSO || liveQSO) ? qsTr("Add QSO") : qsTr("Edit QSO")
    anchors.margins: 5

    property bool addQSO: true;
    property bool liveQSO: false;
    property bool updateQSO: false;

    property int rid;

    property alias date: dateTextField.text;
    property alias time: timeTextField.text;
    property alias call: callTextField.text;
    property alias freq: freqTextField.text
    property alias sent: sentTextField.text;
    property alias recv: recvTextField.text;
    property alias name: nameTextField.text;
    property alias ctry: ctryTextField.text;
    property alias grid: gridTextField.text;
    property alias qqth: qqthTextField.text;
    property alias comm: commTextField.text;
    property alias ctss: ctssTextField.text;
    property alias ctsr: ctsrTextField.text;
    property alias sota: sotaTextField.text;
    property alias sots: sotsTextField.text;
    property alias satm: satmTextField.text;

    property string mode
    property string satn

    property int sync

    property bool qrzFound: false;

    Component.onCompleted: {
        var i = modeComboBox.find(mode);
        modeComboBox.currentIndex = i;

        var j = satnComboBox.find(satn);
        satnComboBox.currentIndex = j;
    }

    function reset() {
        callTextField.text = ""
        nameTextField.text = ""
        ctryTextField.text = ""
        dateTextField.text = ""
        timeTextField.text = ""
        freqTextField.text = (liveQSO && settings.cqActive) ? settings.cqFreq : ""
        sentTextField.text = ""
        recvTextField.text = ""
        gridTextField.text = ""
        qqthTextField.text = ""
        commTextField.text = ""
        ctssTextField.text = ""
        ctsrTextField.text = ""
        sotaTextField.text = ""
        sotsTextField.text = settings.sotaActive ? settings.mySotaReference : ""
        satmTextField.text = ""
        statusIndicator.Material.accent = Material.Green

        modeComboBox.currentIndex = 0;
        satnComboBox.currentIndex = 0;
    }

    function save() {
        if(addQSO == true || liveQSO == true) {
            qsoModel.addQSO(callTextField.text,
                    nameTextField.text,
                    ctryTextField.text,
                    dateTextField.text,
                    timeTextField.text,
                    freqTextField.text,
                    modeComboBox.currentText,
                    sentTextField.text,
                    recvTextField.text,
                    gridTextField.text,
                    qqthTextField.text,
                    commTextField.text,
                    ctssTextField.text,
                    ctsrTextField.text,
                    sotaTextField.text,
                    sotsTextField.text,
                    satnComboBox.currentText,
                    satmTextField.text
                    );

            if(addQSO) {
                stackView.pop()
            } else if(liveQSO) {
                var tmp = ctssTextField.text;
                page.reset();
                if(settings.contestActive && liveQSO) {
                    if(isNaN(tmp)) { // If it is e.g. a province
                        ctssTextField.text = tmp;
                    } else { // if its a running number
                        var contestNumber = parseInt(tmp);
                        contestNumber += 1;
                        ctssTextField.text = contestNumber;
                        settings.contestNumber = contestNumber;
                    }
                    sentTextField.text = 59;
                    recvTextField.text = 59;
                }
            }

        } else if(updateQSO == true) {
            qsoModel.updateQSO(rid,
                       callTextField.text,
                       nameTextField.text,
                       ctryTextField.text,
                       dateTextField.text,
                       timeTextField.text,
                       freqTextField.text,
                       modeComboBox.currentText,
                       sentTextField.text,
                       recvTextField.text,
                       gridTextField.text,
                       qqthTextField.text,
                       commTextField.text,
                       ctssTextField.text,
                       ctsrTextField.text,
                       sotaTextField.text,
                       sotsTextField.text,
                       satnComboBox.currentText,
                       satmTextField.text
                       );
            stackView.pop()
        }
    }

    Timer {
        id: rigTimer
        interval: 1000
        repeat: liveQSO && settings.rigActive
        running: liveQSO && settings.rigActive
        triggeredOnStart: liveQSO && settings.rigActive
        onTriggered: {
            rig.getFrequency(settings.rigHost, settings.rigPort)
            rig.getMode(settings.rigHost, settings.rigPort)
        }
    }

    Connections{
        target: rig

        onFreqDone: {
            freqTextField.text = freq
        }

        onModeDone: {
            var m
            if(mode == "USB" || mode == "LSB") {
                m = "SSB"
            } else {
                m = mode
            }
            var i = modeComboBox.find(m);
            modeComboBox.currentIndex = i;
        }
    }

    Connections{
        target: qrz
        onQrzDone: {
            if (nameTextField.text.length == 0) {
                nameTextField.text = fname + " " + name
            }
            if (ctryTextField.text.length == 0) {
                ctryTextField.text = country
            }
            if (gridTextField.text.length == 0) {
                gridTextField.text = locator
            }
            if (qqthTextField.text.length == 0) {
                qqthTextField.text = addr2
            }

            page.qrzFound = true
        }

        onQrzFail: {
            if(error == "Session Timeout") {
                qrz.receiveKey();
                qrz.lookupCall(callTextField.text);
            } else {
                page.qrzFound = false
            }
        }
    }

    DatePicker {
        id: datePicker
        modal: true
        onClosed: {
            var day = new Date(datePicker.selectedDate)
            dateTextField.text = Qt.formatDateTime(day, "dd.MM.yyyy");
        }
    }

    TimePicker {
        id: timePicker
        modal: true
        onClosed: {
            timeTextField.text = timePicker.selectedTime
        }
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: -1

        ButtonGroup {
            buttons: grid.children
        }

        GridLayout {
            id: grid
            columns: 4
            width: page.width // Important

            Label {
                id: dateLable
                text: qsTr("Date") + ":"
            }

            RowLayout {
                Layout.columnSpan: 3
                QSOTextField {
                    id: dateTextField
                    text: ""
                    placeholderText: "DD.MM.YYYY"
                    KeyNavigation.tab: timeTextField
                    Layout.fillWidth: true

                    Timer {
                        id: dateTextTimer
                        interval: 1000
                        repeat: liveQSO
                        running: liveQSO
                        triggeredOnStart: liveQSO
                        onTriggered: {
                            var now = new Date();
                            var utc = new Date(now.getTime() + now.getTimezoneOffset() * 60000);
                            dateTextField.text = Qt.formatDateTime(utc, "dd.MM.yyyy");
                        }
                    }
                }

                IconButton {
                    id: calButton
                    enabled: !liveQSO
                    width: height
                    Layout.preferredWidth: height
                    font.family: fontAwesome.name
                    buttonIcon: "\uf073"
                    text: ""
                    highlighted: true
                    Material.theme:  Material.Light
                    Material.accent: Material.Green
                    padding: 0

                    onClicked: {
                        datePicker.open()
                    }
                }
            }

            Label {
                id: timeLable
                text: qsTr("Time") + ":"
            }

            RowLayout {
                Layout.columnSpan: 3
                QSOTextField {
                    id: timeTextField
                    text: ""
                    placeholderText: "00:00"
                    KeyNavigation.tab: callTextField
                    Layout.columnSpan: 2
                    Layout.fillWidth: true

                    Timer {
                        id: timeTextTimer
                        interval: 1000
                        repeat: liveQSO
                        running: liveQSO
                        triggeredOnStart: liveQSO
                        onTriggered: {
                            var now = new Date();
                            var utc = new Date(now.getTime() + now.getTimezoneOffset() * 60000);
                            timeTextField.text = Qt.formatDateTime(utc, "HH:mm");
                        }
                    }
                }

                IconButton {
                    id: timeButton
                    enabled: !liveQSO
                    width: height
                    Layout.preferredWidth: height
                    font.family: fontAwesome.name
                    buttonIcon: "\uf017"
                    text: ""
                    highlighted: true
                    Material.theme:  Material.Light
                    Material.accent: Material.Green
                    padding: 0

                    onClicked: {
                        timePicker.open()
                    }
                }
            }

            Label {
                id: callSignLable
                text: qsTr("Callsign") + ":"
            }

            RowLayout {
                Layout.columnSpan: 3

                QSOTextField {
                    id: callTextField
                    text: ""
                    KeyNavigation.tab: modeComboBox
                    font.capitalization: Font.AllUppercase
                    inputMethodHints: Qt.ImhUppercaseOnly

                    onEditingFinished: {
                        if(settings.qrzActive) {
                            qrz.lookupCall(callTextField.text)
                        }

                        if(settings.contestActive) {
                            if(qsoModel.checkCall(callTextField.text)) {
                                statusIndicator.Material.accent = Material.Red
                            } else {
                                statusIndicator.Material.accent = Material.Green
                            }

                        }
                    }
                }

                IconButton {
                    id: statusIndicator
                    visible: settings.contestActive
                    enabled: settings.contestActive
                    width: height
                    Layout.preferredWidth: height
                    font.family: fontAwesome.name
                    buttonIcon: "\uf01e"
                    text: ""
                    highlighted: true
                    Material.theme:  Material.Light
                    Material.accent: Material.Green
                    padding: 0

                    onClicked: {
                        // TODO show previous contacts...
                        var tmp = ctssTextField.text;
                        page.reset();
                        if(settings.contestActive) {
                            ctssTextField.text = tmp;
                            sentTextField.text = 59;
                            recvTextField.text = 59;
                        }
                    }
                }

                IconButton {
                    id: qrzButton
                    width: height
                    Layout.preferredWidth: height
                    font.family: fontAwesome.name
                    buttonIcon: "\uf7a2"
                    text: ""
                    highlighted: qrzFound
                    Material.theme:  Material.Light
                    Material.accent: Material.Green
                    enabled: qrzFound && settings.qrzActive
                    padding: 0

                    onClicked: {
                        stackView.push("QRZView.qml",
                                   {
                                       "call" : callTextField.text
                                   });
                    }
                }

            }

            Label {
                id: modeLable
                text: qsTr("Mode") + ":"
            }

            ComboBox {
                id: modeComboBox
                Layout.columnSpan: 3
                Layout.fillWidth: true
                KeyNavigation.tab: freqTextField
                model: [
                    "SSB",
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
                    "ROS"
                ]
            }

            Label {
                id: freqLable
                text: qsTr("Frequency") + ":"
            }

            QSOTextField {
                id: freqTextField
                Layout.columnSpan: 3
                text: (liveQSO && settings.cqActive) ? settings.cqFreq : ""
                KeyNavigation.tab: sentTextField
                inputMethodHints: Qt.ImhFormattedNumbersOnly

                onEditingFinished: {
                    freqTextField.text = freqTextField.text.replace(",", ".");
                }
            }

            Label {
                id: sentLable
                text: "RST (S):"
            }

            QSOTextField {
                id: sentTextField
                Layout.columnSpan: 1
                text: settings.contestActive ? "59" : ""
                placeholderText: "59"
                KeyNavigation.tab: recvTextField
                inputMethodHints: Qt.ImhDigitsOnly
            }

            Label {
                id: recvLable
                text: "RST (R):"
            }

            QSOTextField {
                id: recvTextField
                Layout.columnSpan: 1
                text: settings.contestActive ? "59" : ""
                placeholderText: "59"
                KeyNavigation.tab: settings.contestActive ? ctssTextField : nameTextField
                inputMethodHints: Qt.ImhDigitsOnly
            }

            Label {
                id: ctssLable
                text: "Contest (S):"
                visible: settings.contestActive || ctssTextField.text || ctsrTextField.text
            }

            QSOTextField {
                id: ctssTextField
                Layout.columnSpan: 1
                text: ""
                KeyNavigation.tab: ctsrTextField
                visible: settings.contestActive || ctssTextField.text || ctsrTextField.text
            }

            Label {
                id: ctsrLable
                text: "Contest (R):"
                visible: settings.contestActive || ctsrTextField.text || ctssTextField.text
            }

            QSOTextField {
                id: ctsrTextField
                Layout.columnSpan: 1
                text: ""
                KeyNavigation.tab: nameTextField
                visible: settings.contestActive || ctsrTextField.text || ctssTextField.text
            }

            Label {
                id: nameLable
                text: qsTr("Name") + ":"
            }

            QSOTextField {
                id: nameTextField
                Layout.columnSpan: 3
                text: ""
                KeyNavigation.tab: qqthTextField
            }

            Label {
                id: qqthLable
                text: qsTr("QTH") + ":"
            }

            QSOTextField {
                id: qqthTextField
                Layout.columnSpan: 3
                text: ""
                KeyNavigation.tab: ctryTextField
            }

            Label {
                id: ctryLable
                text: qsTr("Country") + ":"
            }

            QSOTextField {
                id: ctryTextField
                Layout.columnSpan: 3
                text: ""
                KeyNavigation.tab: gridTextField
            }

            Label {
                id: gridLable
                text: qsTr("Locator") + ":"
            }

            QSOTextField {
                id: gridTextField
                Layout.columnSpan: 3
                text: ""
                KeyNavigation.tab: settings.sotaActive ? sotsTextField : ( settings.satActive ? satnComboBox : commTextField)
            }

            //--- SOTA:

            Label {
                id: mySotaable
                text: qsTr("SOTA (S)") + ":"
                visible: settings.sotaActive || sotaTextField.text || sotsTextField.text
            }

            QSOTextField {
                id: sotsTextField
                Layout.columnSpan: 1
                text: (addQSO == true || liveQSO == true) ? (settings.sotaActive ? settings.mySotaReference : "") : sotsTextField.text
                KeyNavigation.tab: sotaTextField
                visible: settings.sotaActive || sotaTextField.text || sotsTextField.text
            }

            Label {
                id: sotaLable
                text: qsTr("SOTA (R)") + ":"
                visible: settings.sotaActive || sotaTextField.text || sotsTextField.text
            }

            QSOTextField {
                id: sotaTextField
                Layout.columnSpan: 1
                text: ""
                KeyNavigation.tab: (settings.satActive || (satnComboBox.currentIndex !== 0) || satmTextField.text) ? satnComboBox : commTextField
                visible: settings.sotaActive || sotaTextField.text || sotsTextField.text
            }

            //--- SAT:

            Label {
                id: mySatLaable
                text: qsTr("SAT Name") + ":"
                visible: settings.satActive || (satnComboBox.currentIndex !== 0) || satmTextField.text
            }

            ComboBox {
                id: satnComboBox
                Layout.fillWidth: true
                KeyNavigation.tab: satmTextField
                model: [
                    "",
                    "AISAT-1",
                    "ARISS",
                    "AO-7",
                    "AO-27",
                    "AO-73",
                    "AO-91",
                    "AO-92",
                    "CAS-3H",
                    "CAS-4A",
                    "CAS-4B",
                    "CAS-6",
                    "EO-88",
                    "FO-29",
                    "FO-99",
                    "FS-3",
                    "HO-107",
                    "IO-86",
                    "Lilacsat-1",
                    "NO-84",
                    "NO-104",
                    "PO-101",
                    "QO-100",
                    "RS-44",
                    "SO-50",
                    "XW-2A",
                    "XW-2B",
                    "XW-2C",
                    "XW-2D",
                    "XW-2F",
                ]
                visible: settings.satActive || (satnComboBox.currentIndex !== 0) || satmTextField.text
            }

            Label {
                id: satModeLable
                text: qsTr("SAT Mode") + ":"
                visible: settings.satActive || (satnComboBox.currentIndex !== 0) || satmTextField.text
            }

            QSOTextField {
                id: satmTextField
                Layout.columnSpan: 1
                text: ""
                KeyNavigation.tab: commTextField
                visible: settings.satActive || (satnComboBox.currentIndex !== 0) || satmTextField.text
            }

            //--- Comments:

            Label {
                id: commLable
                text: qsTr("Comment") + ":"
            }

            QSOTextField {
                id: commTextField
                Layout.columnSpan: 3
                text: ""
                KeyNavigation.tab: saveButton
            }

            Button {
                id: resetButton
                text: qsTr("Reset")
                visible: (addQSO || liveQSO)

                onClicked: {
                    var tmp = ctssTextField.text;
                    page.reset();
                    if(settings.contestActive) {
                        ctssTextField.text = tmp;
                        sentTextField.text = 59;
                        recvTextField.text = 59;
                    }
                }
            }

            Label {
                id: resetButtonPlaceHolder
                text: ""
                visible: updateQSO
            }

            IconButton {
                id: saveButton
                Layout.columnSpan: 3
                text: qsTr("Save QSO")
                buttonIcon: "\uf0c7"
                Layout.fillWidth: true
                highlighted: true
                Material.theme: Material.Light
                Material.accent: Material.Green

                onClicked: {
                    save();
                }
            }
        }
    }
}
