import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls.Material 2.4

Page {
    id: page
    anchors.fill: parent
    title: qsTr("Add QSO")
    anchors.margins: 10

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
