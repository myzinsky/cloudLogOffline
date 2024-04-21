import QtQuick.Layouts
import QtQuick.Controls

Button {
    id: button
    property string buttonIcon: ""
    implicitWidth: 48

    contentItem: Label {

        RowLayout {
            anchors.centerIn: parent

            Label {
                font.family: fontAwesome.name
                text: buttonIcon
                opacity: 0.87
                font.pixelSize: Qt.application.font.pixelSize * 1.6
                color: "#FFFFFF"
            }

            Label {
                text: button.text.toUpperCase()
                font: button.font
                opacity: 0.87
                color: "#FFFFFF"
            }
        }
    }
}
