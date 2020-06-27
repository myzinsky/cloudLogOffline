import QtQuick 2.12
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
    property alias mode: modeComboBox.currentText;
    property alias freq: freqTextField.text
    property alias sent: sentTextField.text;
    property alias recv: recvTextField.text;
    property alias name: nameTextField.text;
    property alias ctry: ctryTextField.text;
    property alias grid: gridTextField.text;
    property alias qqth: qqthTextField.text;
    property alias comm: commTextField.text;
    property int   sync

    property bool qrzFound: false;

    function reset() {
        callTextField.text = ""
        nameTextField.text = ""
        ctryTextField.text = ""
        dateTextField.text = ""
        timeTextField.text = ""
        freqTextField.text = (liveQSO && settings.cqActive) ? settings.cqFreq : ""
        // TODO: modeComboBox.
        sentTextField.text = ""
        recvTextField.text = ""
        gridTextField.text = ""
        qqthTextField.text = ""
        commTextField.text = ""
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
                nameTextField.text = fname
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

    ScrollView {
        anchors.fill: parent

        ButtonGroup {
            buttons: grid.children
        }

        GridLayout {
            id: grid
            columns: 3
            width: page.width // Important

            Label {
                id: dateLable
                text: qsTr("Date") + ":"
            }

            QSOTextField {
                id: dateTextField
                Layout.columnSpan: 2
                text: ""
                placeholderText: "DD.MM.YYYY"
                KeyNavigation.tab: timeTextField

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

            Label {
                id: timeLable
                text: qsTr("Time") + ":"
            }

            QSOTextField {
                id: timeTextField
                Layout.columnSpan: 2
                text: ""
                placeholderText: "00:00"
                KeyNavigation.tab: callTextField

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

            Label {
                id: callSignLable
                text: qsTr("Callsign") + ":"
            }

            QSOTextField {
                id: callTextField
                text: ""
                KeyNavigation.tab: modeComboBox
                font.capitalization: Font.AllUppercase

                onEditingFinished: {
                    if(settings.qrzActive) {
                        qrz.lookupCall(callTextField.text)
                    }
                }
            }

            Button {
                id: qrzButton
                font.family: fontAwesome.name
                text: "\uf7a2"
                highlighted: qrzFound
                width: 20
                Material.theme:  Material.Light
                Material.accent: Material.Green
                enabled: settings.qrzActive
                padding: 0

                onClicked: {
                    stackView.push("QRZView.qml",
                                   {
                                       "call" : callTextField.text
                                   });
                }
            }

            Label {
                id: modeLable
                text: qsTr("Mode") + ":"
            }

            ComboBox {
                id: modeComboBox
                Layout.columnSpan: 2
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
                Layout.columnSpan: 2
                text: (liveQSO && settings.cqActive) ? settings.cqFreq : ""
                KeyNavigation.tab: sentTextField
            }

            Label {
                id: sentLable
                text: "RST (S):"
            }

            QSOTextField {
                id: sentTextField
                Layout.columnSpan: 2
                text: ""
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
                Layout.columnSpan: 2
                text: ""
                placeholderText: "59"
                KeyNavigation.tab: nameTextField
                inputMethodHints: Qt.ImhDigitsOnly
            }

            Label {
                id: nameLable
                text: qsTr("Name") + ":"
            }

            QSOTextField {
                id: nameTextField
                Layout.columnSpan: 2
                text: ""
                KeyNavigation.tab: qqthTextField
            }

            Label {
                id: qqthLable
                text: qsTr("QTH") + ":"
            }

            QSOTextField {
                id: qqthTextField
                Layout.columnSpan: 2
                text: ""
                KeyNavigation.tab: gridTextField
            }

            Label {
                id: ctryLable
                text: qsTr("Country") + ":"
            }

            QSOTextField {
                id: ctryTextField
                Layout.columnSpan: 2
                text: ""
                KeyNavigation.tab: gridTextField
            }

            Label {
                id: gridLable
                text: qsTr("Locator") + ":"
            }

            QSOTextField {
                id: gridTextField
                Layout.columnSpan: 2
                text: ""
                KeyNavigation.tab: commTextField
            }

            Label {
                id: commLable
                text: qsTr("Comment") + ":"
            }

            QSOTextField {
                id: commTextField
                Layout.columnSpan: 2
                text: ""
                KeyNavigation.tab: saveButton
            }

            Button {
                id: resetButton
                text: qsTr("Reset")
                visible: (addQSO || liveQSO)

                onClicked: {
                    page.reset();
                }
            }

            Label {
                id: resetButtonPlaceHolder
                text: ""
                visible: updateQSO
            }

            Button {
                id: saveButton
                Layout.columnSpan: 2
                text: qsTr("Save QSO")
                Layout.fillWidth: true
                highlighted: true
                Material.theme: Material.Light
                Material.accent: Material.Green

                onClicked: {
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
                                commTextField.text
                                );

                        if(addQSO) {
                            stackView.pop()
                        } else if(liveQSO) {
                            page.reset();
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
                                   commTextField.text
                                   );
                        stackView.pop()
                    }
                }
            }
        }
    }
}
