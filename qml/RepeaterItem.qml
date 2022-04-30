import QtQuick 2.12
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0

SwipeDelegate {
    width: parent.width
    height: 50

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
        height: 50

        Rectangle {
            color: "#555555"
            height: 50
            width: parent.width

            Rectangle {
                id: callcityrect
                z: 100
                color: "#555555"
                width: call.contentWidth + city.contentWidth + 10
                height: call.contentHeight
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.top: parent.top
                anchors.topMargin: 5
                Text {
                    id: call
                    text: model.call.replace(/0/g,"\u2205").toUpperCase()
                    font.underline: false
                    font.weight: Font.Bold
                    style: Text.Normal
                    font.wordSpacing: 0
                    font.capitalization: Font.Capitalize
                    color: "#607D8B"
                    font.pixelSize: 20
                    font.bold: true
                }

                Text {
                    id: city
                    anchors.top: parent.top
                    anchors.left: call.right
                    anchors.leftMargin: 10
                    color: "#ffffff"
                    text: model.city
                    font.italic: true
                    font.bold: false
                    font.wordSpacing: 0
                    opacity: 0.87
                    font.pixelSize: 20
                }
            }

            Rectangle {
                id: gradient
                z: 100
                color: "transparent"
                anchors.top: parent.top
                anchors.left: callcityrect.right
                anchors.topMargin: 5
                anchors.leftMargin: 0
                height: city.contentHeight
                width: 50
                LinearGradient {
                    anchors.fill: parent
                    start: Qt.point(0,0)
                    end: Qt.point(gradient.width,0)
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#555555" }
                        GradientStop { position: 0.5; color: "#555555" }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
            }

            Text {
                id: modes
                z: 50
                color: "#ffffff"
                text: model.mode
                anchors.rightMargin: 10
                font.italic: false
                font.bold: false
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 5
                font.wordSpacing: 0
                opacity: 0.87
                font.pixelSize: 20
            }

            Text {
                id: freq
                text: model.freq + " MHz"
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.top: parent.top
                anchors.topMargin:30
                anchors.verticalCenter: parent.verticalCenter
                color: "white"
                opacity: 0.87

            }

            Text {
                id: shift
                text: model.shif + " MHz"
                anchors.top: parent.top
                anchors.topMargin: 30
                anchors.left: freq.right
                anchors.leftMargin: 10
                color: "white"
                opacity: 0.87
            }

            Text {
                id: tone
                text: model.tone + (model.tone !== "" ? " Hz" : "")
                anchors.top: parent.top
                anchors.topMargin: 30
                anchors.left: shift.right
                anchors.leftMargin: 10
                color: "white"
                opacity: 0.87
            }

            Text {
                id: dist
                text: Number(model.dist).toFixed(2) + " km"
                anchors.top: parent.top
                anchors.topMargin: 30
                anchors.right: parent.right
                anchors.rightMargin: 10
                color: "white"
                opacity: 0.87
            }
        }
    }

    swipe.right: Rectangle {
        width: 50
        height: 50
        anchors.right: parent.right
        anchors.rightMargin: 0
        clip: true
        color: Material.color(Material.BlueGrey)
        MouseArea {
            id: edit
            anchors.fill: parent

            Text {
                font.family: fontAwesome.name
                text: "\uf055"
                font.pixelSize: Qt.application.font.pixelSize * 1.6
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#ffffff"
                opacity: 0.87
            }

            onClicked: {
                swipe.close()

                var strippedMode = ""

                if(mode.includes("FM")) {
                    strippedMode = "FM";
                } else if(mode.includes("DMR")) {
                    strippedMode = "DMR";
                } else if(mode.includes("Wires")) {
                    strippedMode = "C4FM";
                } else if(mode.includes("D-Star")) {
                    strippedMode = "DSTAR";
                }

                stackView.push("QSOViewWrapper.qml", {
                    "addQSO"     : true,
                    "liveQSO"    : true,
                    "updateQSO"  : false,
                    "mode"       : strippedMode,
                    "freq"       : model.freq,
                    "sent"       : "5",
                    "recv"       : "5",
                    "comm"       : "Via Repeater: " + model.call,
                });
            }
        }
    }

}
