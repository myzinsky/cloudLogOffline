import QtQuick 2.12
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

SwipeDelegate {
    width: parent.width
    height: 70

    padding: 0
    rightPadding: 0
    bottomPadding: 0
    leftPadding: 0
    topPadding: 0

    opacity: 1.0
    scale: 1.0

    checkable: true
    checked: swipe.complete
    onCheckedChanged: if (!checked) swipe.close()

    contentItem: Item {
        id: element
        width: parent.width
        //anchors.fill: parent
        height: 70
        //z: 0
        Rectangle {
            width: parent.width
            height: 70
            color: "#555555"
            id: rec

            Text {
                id:call
                text: model.call.replace("0","\u2205").toUpperCase()
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


            Text {
                id: date
                text: model.date
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.top: parent.top
                anchors.topMargin:30
                anchors.verticalCenter: parent.verticalCenter
                color: "white"
                opacity: 0.87

            }

            Text {
                id: time
                text: model.time
                anchors.top: parent.top
                anchors.topMargin: 30
                anchors.left: date.right
                anchors.leftMargin: 10
                color: "white"
                opacity: 0.87
            }

            Text {
                id: frequency
                color: "#ffffff"
                text: model.freq
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 50
                anchors.leftMargin: 5
                font.pixelSize: 12
                opacity: 0.87
            }

            Text {
                id: mode
                color: "#ffffff"
                text: model.mode
                anchors.left: frequency.right
                anchors.leftMargin: 10
                anchors.top: parent.top
                anchors.topMargin: 50
                font.pixelSize: 12
                opacity: 0.87
            }

            Text {
                id: sent
                color: "#ffffff"
                text: model.sent
                anchors.left: mode.right
                anchors.leftMargin: 10
                anchors.top: parent.top
                anchors.topMargin: 50
                font.pixelSize: 12
                opacity: 0.87
            }

            Text {
                id: recv
                color: "#ffffff"
                text: model.recv
                anchors.left: sent.right
                anchors.leftMargin: 10
                anchors.top: parent.top
                anchors.topMargin: 50
                font.pixelSize: 12
                opacity: 0.87
            }

            Text {
                id: country
                color: "#ffffff"
                text: model.ctry
                anchors.right: parent.right
                anchors.rightMargin: 5
                font.italic: false
                font.bold: false
                anchors.top: parent.top
                anchors.topMargin: 5
                font.wordSpacing: 0
                font.pixelSize: 20
                opacity: 0.87
            }


            Text {
                id: name
                color: "#ffffff"
                text: model.name
                anchors.leftMargin: 10
                font.italic: true
                font.bold: false
                anchors.top: parent.top
                anchors.left: call.right
                anchors.topMargin: 5
                font.wordSpacing: 0
                opacity: 0.87
                font.pixelSize: 20
            }

            Text {
                id: rowNumber
                color: "#ffffff"
                font.family: fontAwesome.name
                text: model.sync === 0 ? "" : "\uf382"
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 50
                anchors.rightMargin: 5
                font.pixelSize: 12
                opacity: 0.87
            }
        }
    }

    swipe.right: Rectangle {
        width: 70
        height: 70
        anchors.right: parent.right
        anchors.rightMargin: 0
        clip: true
        color: Material.color(Material.BlueGrey)
        MouseArea {
            id: edit
            anchors.fill: parent

            Text {
                font.family: fontAwesome.name
                text: "\uf044"
                font.pixelSize: Qt.application.font.pixelSize * 1.6
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#ffffff"
                opacity: 0.87
            }

            onClicked: {
                swipe.close()
                stackView.push("QSOView.qml",
                               {
                                   "addQSO"     : false,
                                   "liveQSO"    : false,
                                   "updateQSO"  : true,

                                   "rid"        : index,
                                   "date"       : model.date,
                                   "time"       : model.time,
                                   "call"       : model.call,
                                   "mode"       : model.mode,
                                   "freq"       : model.freq,
                                   "sent"       : model.sent,
                                   "recv"       : model.recv,
                                   "name"       : model.name,
                                   "ctry"       : model.ctry,
                                   "grid"       : model.grid,
                                   "sync"       : model.sync,
                               });
            }
        }
    }

    swipe.left: Rectangle {
        width: 70
        height: 70
        anchors.left: parent.left
        anchors.leftMargin: 0
        clip: true
        color: Material.color(Material.Red)
        MouseArea {
            id: del
            anchors.fill: parent

            Text {
                font.family: fontAwesome.name
                text: "\uf2ed"
                font.pixelSize: Qt.application.font.pixelSize * 1.6
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#ffffff"
                opacity: 0.87
            }

            onClicked: {
                qsoModel.deleteQSO(index)
            }
        }
    }
}
