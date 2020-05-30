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
        //anchors.margins: 5
        spacing: 5

        ButtonGroup {
            buttons: listView.contentItem.children
        }

        delegate: QSOItem {}

        remove: Transition {
               NumberAnimation { property: "opacity"; from: 1.0; to: 0; duration: 400 }
               NumberAnimation { property: "scale"; from: 1.0; to: 0.0; duration: 400 }
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
