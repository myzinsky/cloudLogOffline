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
                id: callsSignTextField
                text: ""
                Layout.fillWidth: true
            }

            Label {
                id: modeLable
                text: qsTr("Mode:")
            }

            ComboBox {
                id: dateComboBox
                Layout.fillWidth: true
            }

            Label {
                id: bandLable
                text: qsTr("Band:")
            }

            ComboBox {
                id: bandComboBox
                Layout.fillWidth: true
            }

            Label {
                id: rstsLable
                text: qsTr("RST (S):")
            }

            TextField {
                id: rstsComboBox
                text: ""
                placeholderText: qsTr("59")
                Layout.fillWidth: true
            }

            Label {
                id: rstrLable
                text: qsTr("RST (R):")
            }

            TextField {
                id: rstrComboBox
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
                id: commentLable
                text: qsTr("Comment:")
            }

            TextField {
                id: commentTextField
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
                    qso.someSlot()
                }
            }
        }
    }
}
