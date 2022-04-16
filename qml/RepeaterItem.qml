import QtQuick 2.12
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

Item {

    id: element
    width: parent.width
    height: 70

    Rectangle {
        width: parent.width
        height: 70
        color: "#555555"
        id: rec

        Text {
            id:call
            text: model.call.replace(/0/g,"\u2205").toUpperCase()
            font.underline: false
            font.weight: Font.Bold
            style: Text.Normal
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: parent.top
            anchors.topMargin: 5
            font.wordSpacing: 0
            font.capitalization: Font.Capitalize
            color: "#607D8B"
            font.pixelSize: 20
            font.bold: true
        }
    }
}
