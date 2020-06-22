import QtQuick 2.12
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.4
import Qt.labs.settings 1.0

Button {
    id: button
    property string buttonIcon: ""
    width: 48

    contentItem: Label {
        id: label0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        GridLayout {
            id: label1
            columns: 2
            x: ( label0.width / 2 ) - ( label2.width + label3.width ) /2
            y: ( label0.height / 2 ) - ( Math.max(label2.height, label3.height) ) /2
            width: label2.width + label3.width

            Label {
                id: label2
                font.family: fontAwesome.name
                text: buttonIcon
                opacity: 0.87
                font.pixelSize: Qt.application.font.pixelSize * 1.6
                color: "#FFFFFF"
            }

            Label {
                id: label3
                text: button.text.toUpperCase()
                font: button.font
                opacity: 0.87
                color: "#FFFFFF"
            }
        }
    }
}
