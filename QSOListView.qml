import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1
import Qt.labs.qmlmodels 1.0

Page {
    id: qsoListView
    title: qsTr("Logbook")
    anchors.fill: parent
    anchors.margins: 5

    ListView {
        id: listView
        anchors.fill: parent
        model: qsoModel
        spacing: 5

        ButtonGroup {
            buttons: listView.contentItem.children
        }

        delegate: QSOItem {}

        remove: Transition {
            SequentialAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 1.0
                    to: 0
                    duration: 400
                }
                // Commit database after the actual animation
                ScriptAction {
                    script: {
                        qsoModel.select()
                    }
                }
            }
        }

        removeDisplaced:Transition{
            NumberAnimation{
                property:"y"
                duration:400
                easing.type: Easing.InOutQuad
            }
        }


        ScrollBar.vertical: ScrollBar {}

        // Show a placeholder when no QSO is in the list so far
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
