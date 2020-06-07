import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1

Rectangle {
    height: 48
    color: "#555555"
    Layout.fillWidth: true

    property alias checked: settingsSwitch.checked
    property alias icon:    settingsIcon.text
    property alias text:    settingsText.text

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
        anchors.leftMargin: 5
        font.pixelSize: 14
        opacity: 0.87
        anchors.verticalCenter: parent.verticalCenter
    }

    Switch {
        id: settingsSwitch
        anchors.right: parent.right
        anchors.rightMargin: 0
        checked: false;
    }
}
