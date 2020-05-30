import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1
import Qt.labs.qmlmodels 1.0

Page {
    id: qsoListView
    title: qsTr("Logbook")
    anchors.fill: parent
    anchors.margins: 1

    ListView {
        id: listView
        anchors.fill: parent
        model: qsoModel
        anchors.margins: 5
        spacing: 5

        ButtonGroup {
            buttons: listView.contentItem.children
        }

        delegate: QSOItem {}

        remove: Transition {
            SequentialAnimation {
                PauseAnimation {
                    duration: 125
                }
                NumberAnimation {
                    property: "height"
                    to: 0
                    easing.type: Easing.InOutQuad
                }
            }
        }

        displaced: Transition {
            SequentialAnimation {
                PauseAnimation {
                    duration: 125
                }
                NumberAnimation {
                    property: "y";
                    easing.type: Easing.InOutQuad
                }
            }
        }

        ScrollBar.vertical: ScrollBar {}

        Label {
            id: placeholder
            text: qsTr("Add QSOs in Menu")

            anchors.margins: 60
            anchors.fill: parent

            opacity: 0.5
            visible: listView.count === 0

            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            wrapMode: Label.WordWrap
            font.pixelSize: 18
        }
    }
}
