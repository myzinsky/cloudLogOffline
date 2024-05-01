import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12

SwipeDelegate {
    id: swipeDelegateId
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
                text: model.mode + (model.propmode ? (" (" + model.propmode + ")") : "")
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
                text: "S:" + model.sent + (model.ctss ? (" [" + model.ctss + "]") : "")
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
                text: "R:" + model.recv + (model.ctsr ? (" [" + model.ctsr + "]") : "")
                anchors.left: sent.right
                anchors.leftMargin: 10
                anchors.top: parent.top
                anchors.topMargin: 50
                font.pixelSize: 12
                opacity: 0.87
            }

            Rectangle {
                id: countryrect
                z: 100
                color: "#555555"
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.top: parent.top
                anchors.topMargin: 5
                width: country.contentWidth + 5
                height: country.contentHeight

                Text {
                    id: country
                    color: "#ffffff"
                    text: model.ctry
                    font.italic: false
                    font.bold: false
                    font.wordSpacing: 0
                    font.pixelSize: 20
                    opacity: 0.87
                }
            }

            Rectangle {
                id: gradient
                z: 100
                color: "transparent"
                anchors.top: parent.top
                anchors.right: countryrect.left
                anchors.topMargin: 5
                anchors.rightMargin: 0
                height: country.contentHeight
                width: 50
                LinearGradient {
                    anchors.fill: parent
                    start: Qt.point(gradient.width,0)
                    end: Qt.point(0,0)
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#555555" }
                        GradientStop { position: 0.5; color: "#555555" }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
            }


            Text {
                id: name
                color: "#ffffff"
                text: model.name
                width: swipeDelegateId.width - call.width - country.width - 20;
                elide: Text.ElideRight
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

            //--- SOTA

            Text {
                id: sotaLogo
                color: "#ffffff"
                font.family: fontAwesome.name
                text: (model.sota !== "" || model.sots !== "") ? "\uf6fc" : ""
                anchors.top: parent.top
                anchors.right: sotaName.left
                anchors.topMargin: 50
                anchors.rightMargin: (model.sota !== "" || model.sots !== "") ? 5 : 0
                font.pixelSize: 12
                opacity: 0.87
            }

            Text {
                id: sotaName
                color: "#ffffff"
                text: (model.sota !== "" || model.sots !== "") ? "S:" + model.sots + " R:" + model.sota : ""
                anchors.top: parent.top
                anchors.right: satLogo.left
                anchors.topMargin: 50
                anchors.rightMargin: (model.sota !== "" || model.sots !== "") ? 5 : 0
                font.pixelSize: 12
                opacity: 0.87
            }

            //--- WWFF

            Text {
                id: wwffLogo
                color: "#ffffff"
                font.family: fontAwesome.name
                text: (model.wwff !== "" || model.wwfs !== "") ? "\uf1bb" : ""
                anchors.top: parent.top
                anchors.right: wwffName.left
                anchors.topMargin: 50
                anchors.rightMargin: (model.wwff !== "" || model.wwfs !== "") ? 5 : 0
                font.pixelSize: 12
                opacity: 0.87
            }

            Text {
                id: wwffName
                color: "#ffffff"
                text: (model.wwff !== "" || model.wwfs !== "") ? "S:" + model.wwfs + " R:" + model.wwff : ""
                anchors.top: parent.top
                anchors.right: potaLogo.left
                anchors.topMargin: 50
                anchors.rightMargin: (model.wwff !== "" || model.wwfs !== "") ? 5 : 0
                font.pixelSize: 12
                opacity: 0.87
            }

            //--- POTA

            Text {
                id: potaLogo
                color: "#ffffff"
                font.family: fontAwesome.name
                text: (model.pota !== "" || model.pots !== "") ? "\uf540" : ""
                anchors.top: parent.top
                anchors.right: potaName.left
                anchors.topMargin: 50
                anchors.rightMargin: (model.pota !== "" || model.pots !== "") ? 5 : 0
                font.pixelSize: 12
                opacity: 0.87
            }

            Text {
                id: potaName
                color: "#ffffff"
                text: (model.pota !== "" || model.wwfs !== "") ? "S:" + model.pots + " R:" + model.pota : ""
                anchors.top: parent.top
                anchors.right: satLogo.left
                anchors.topMargin: 50
                anchors.rightMargin: (model.pota !== "" || model.pots !== "") ? 5 : 0
                font.pixelSize: 12
                opacity: 0.87
            }

            //--- SAT

            Text {
                id: satLogo
                color: "#ffffff"
                font.family: fontAwesome.name
                text: model.satn !== "" ? "\uf7bf" : ""
                anchors.top: parent.top
                anchors.right: satName.left
                anchors.topMargin: 50
                anchors.rightMargin: model.satn !== "" ? 5 : 0
                font.pixelSize: 12
                opacity: 0.87
            }

            Text {
                id: satName
                color: "#ffffff"
                text: model.satn
                anchors.top: parent.top
                anchors.right: syncStatus.left
                anchors.topMargin: 50
                anchors.rightMargin: model.satn !== "" ? 5 : 0
                font.pixelSize: 12
                opacity: 0.87
            }

            Text {
                id: syncStatus
                color: "#ffffff"
                font.family: fontAwesome.name
                text: model.sync === 0 ? "" : "\uf382"
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 50
                anchors.rightMargin: model.sync !== 0 ? 5 : 0
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
                console.log("Goto QSOViewWrapper.qml")
                stackView.push("QSOViewWrapper.qml", {
                    "addQSO"      : false,
                    "liveQSO"     : false,
                    "updateQSO"   : true,
                    "repeaterQSO" : false,

                    "rid"         : index,
                    "date"        : model.date,
                    "time"        : model.time,
                    "call"        : model.call,
                    "mode"        : model.mode,
                    "freq"        : model.freq,
                    "sent"        : model.sent,
                    "recv"        : model.recv,
                    "name"        : model.name,
                    "ctry"        : model.ctry,
                    "grid"        : model.grid,
                    "qqth"        : model.qqth,
                    "comm"        : model.comm,
                    "ctss"        : model.ctss,
                    "ctsr"        : model.ctsr,
                    "sync"        : model.sync,
                    "sota"        : model.sota,
                    "sots"        : model.sots,
                    "wwff"        : model.wwff,
                    "wwfs"        : model.wwfs,
                    "pota"        : model.pota,
                    "pots"        : model.pots,
                    "satn"        : model.satn,
                    "satm"        : model.satm,
                    "propmode"    : model.propmode,
                    "rxfreq"      : model.rxfreq,
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
