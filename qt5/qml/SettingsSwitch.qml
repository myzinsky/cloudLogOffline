import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import Qt.labs.platform 1.0

Rectangle {
    height: 48
    color: "#555555"
    Layout.fillWidth: true

    property alias checked: settingsSwitch.checked
    property alias icon:    settingsIcon.text
    property alias text:    settingsText.text
    property alias helpText: helpMessage.text


    MessageDialog {
        id: helpMessage
        buttons: StandardButton.Ok
    }

    Label {
        id: settingsIcon
        font.family: fontAwesome.name
        anchors.left: parent.left
        anchors.leftMargin: 5
        font.pixelSize: Qt.application.font.pixelSize * 1.6
        opacity: 0.87
        anchors.verticalCenter: parent.verticalCenter
    }

    Label {
        id: settingsText
        anchors.left: settingsIcon.right
        anchors.leftMargin: 10
        font.pixelSize: 14
        opacity: 0.87
        anchors.verticalCenter: parent.verticalCenter
    }

    IconButton {
        buttonIcon: "\uf059"
        anchors.right: settingsSwitch.left
        anchors.leftMargin: 0
        flat: true
        anchors.verticalCenter: parent.verticalCenter
        onClicked: {
            helpMessage.open();
        }
    }

    Switch {
        id: settingsSwitch
        anchors.right: parent.right
        anchors.rightMargin: 0
        onToggled: saveSettings()
        anchors.verticalCenter: parent.verticalCenter
    }
}
