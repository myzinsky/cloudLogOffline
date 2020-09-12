import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls.Material 2.4
import Qt.labs.platform 1.1

Rectangle {
    height: 48
    color: "#555555"
    Layout.fillWidth: true

    property alias checked: settingsSwitch.checked
    property alias icon:    settingsIcon.text
    property alias text:    settingsText.text

    property alias helpText: helpMessage.text

    Label {
        id: settingsIcon
        font.family: fontAwesome.name
        anchors.left: parent.left
        anchors.leftMargin: 5
        font.pixelSize: Qt.application.font.pixelSize * 1.6
        opacity: 0.87
        anchors.verticalCenter: parent.verticalCenter
    }

    MessageDialog {
        id: helpMessage
        buttons: MessageDialog.Ok
    }

    Label {
        id: settingsText
        anchors.left: settingsIcon.right
        anchors.leftMargin: 5
        font.pixelSize: 14
        opacity: 0.87
        anchors.verticalCenter: parent.verticalCenter
    }

    IconButton {
        buttonIcon: "\uf059"
        anchors.right: settingsSwitch.left
        anchors.leftMargin: 0
        flat: true
        onClicked: {
            helpMessage.open();
        }
    }

    Switch {
        id: settingsSwitch
        anchors.right: parent.right
        anchors.rightMargin: 0
        onToggled: saveSettings()
    }
}
