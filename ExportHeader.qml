import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls.Material 2.4
import Qt.labs.platform 1.1

Rectangle {
    height: 48
    color: "#555555"
    Layout.fillWidth: true

    property alias icon:    exportIcon.text
    property alias text:    exportText.text
    property alias helpText: helpMessage.text

    Label {
        id: exportIcon
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
        id: exportText
        anchors.left: exportIcon.right
        anchors.leftMargin: 5
        font.pixelSize: 14
        opacity: 0.87
        anchors.verticalCenter: parent.verticalCenter
    }

    IconButton {
        buttonIcon: "\uf059"
        anchors.right: parent.right
        anchors.rightMargin: 0
        flat: true
        onClicked: {
            helpMessage.open();
        }
    }
}
