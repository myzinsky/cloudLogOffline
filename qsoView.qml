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
    }

    Connections{
        target: qrz
        onQrzDone: {
            nameTextField.text = name
            ctryTextField.text = ctry
        }
    }

    ScrollView {
        anchors.fill: parent

        ButtonGroup {
            buttons: grid.children
        }

        GridLayout {
            id: grid
            columns: 2
            width: page.width // Important

            Label {
                id: dateLable
                text: qsTr("Date:")
            }

            QSOTextField {
                id: dateTextField
                text: ""
                placeholderText: qsTr("DD.MM.YYYY")
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
                text: qsTr("Time:")

            }

            QSOTextField {
                id: timeTextField
                text: ""
                placeholderText: qsTr("00:00")
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
                text: qsTr("Callsign:")
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

            Label {
                id: modeLable
                text: qsTr("Mode:")
            }

            ComboBox {
                id: modeComboBox
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
                text: qsTr("Frequency:")
            }

            QSOTextField {
                id: freqTextField
                text: (liveQSO && settings.cqActive) ? settings.cqFreq : ""
                KeyNavigation.tab: sentTextField
            }

            Label {
                id: sentLable
                text: qsTr("RST (S):")
            }

            QSOTextField {
                id: sentTextField
                text: ""
                placeholderText: qsTr("59")
                KeyNavigation.tab: recvTextField
            }

            Label {
                id: recvLable
                text: qsTr("RST (R):")
            }

            QSOTextField {
                id: recvTextField
                text: ""
                placeholderText: qsTr("59")
                KeyNavigation.tab: nameTextField
            }

            Label {
                id: nameLable
                text: qsTr("Name:")
            }

            QSOTextField {
                id: nameTextField
                text: ""
                KeyNavigation.tab: ctryTextField
            }

            Label {
                id: ctryLable
                text: qsTr("Country:")
            }

            QSOTextField {
                id: ctryTextField
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
                                recvTextField.text);

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
                                   recvTextField.text);
                        stackView.pop()
                    }
                }
            }
        }
    }
}
