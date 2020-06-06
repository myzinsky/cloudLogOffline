import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls.Material 2.4

Page {
    id: page
    anchors.fill: parent
    title: qsTr("Add QSO")
    anchors.margins: 10

    property bool addQSO: true;
    property bool liveQSO: false;

    property alias date: dateTextField.text;
    property alias time: timeTextField.text;
    property alias call: callTextField.text;
    property alias mode: modeComboBox.currentText;
    property alias freq: freqTextField.text
    property alias sent: sentTextField.text;
    property alias recv: recvTextField.text;
    property alias name: nameTextField.text;
    property alias ctry: ctryTextField.text;

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

            TextField {
                id: dateTextField
                text: ""
                placeholderText: qsTr("DD.MM.YYYY")
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

            Label {
                id: timeLable
                text: qsTr("Time:")

            }

            TextField {
                id: timeTextField
                text: ""
                placeholderText: qsTr("00:00")
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

            Label {
                id: callSignLable
                text: qsTr("Callsign:")
            }

            TextField {
                id: callTextField
                text: ""
                Layout.fillWidth: true
            }

            Label {
                id: modeLable
                text: qsTr("Mode:")
            }

            ComboBox {
                id: modeComboBox
                Layout.fillWidth: true
            }

            Label {
                id: freqLable
                text: qsTr("Frequency:")
            }

            TextField {
                id: freqTextField
                text: ""
                Layout.fillWidth: true
            }

            Label {
                id: sentLable
                text: qsTr("RST (S):")
            }

            TextField {
                id: sentTextField
                text: ""
                placeholderText: qsTr("59")
                Layout.fillWidth: true
            }

            Label {
                id: recvLable
                text: qsTr("RST (R):")
            }

            TextField {
                id: recvTextField
                text: ""
                placeholderText: qsTr("59")
                Layout.fillWidth: true
            }

            Label {
                id: nameLable
                text: qsTr("Name:")
            }

            TextField {
                id: nameTextField
                text: ""
                Layout.fillWidth: true
            }

            Label {
                id: ctryLable
                text: qsTr("Country:")
            }

            TextField {
                id: ctryTextField
                text: ""
                Layout.fillWidth: true
            }

            Button {
                id: resetButton
                text: qsTr("Reset")
            }

            Button {
                id: saveButton
                text: qsTr("Save QSO")
                Layout.fillWidth: true
                highlighted: true
                Material.theme: Material.Light
                Material.accent: Material.Green

                onClicked: {
                    if(addQSO == true) {
                        qsoModel.addQSO(callTextField.text,
                                nameTextField.text,
                                ctryTextField.text,
                                dateTextField.text,
                                timeTextField.text,
                                freqTextField.text,
                                modeComboBox.text,
                                sentTextField.text,
                                recvTextField.text);
                    }
                }
            }
        }
    }
}
