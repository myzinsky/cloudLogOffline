import QtQuick 2.0
import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1
import de.webappjung 1.0

Page {
    id: page
    title: (rb.getLocator() === "") ? qsTr("Hear HAM Repeater List") : qsTr("Hear HAM Repeater List") + " (" + rb.getLocator() + ")";
    Layout.margins: 5

    Component.onCompleted: {
        if(settings.rbActive) {
            rb.getRepeaters();
        }
    }

    ListView {
        id: rmListView
        anchors.fill: parent
        spacing: 5

        Connections{
            target: rb
            function onLocatorDone(locator) {
                page.title = qsTr("Hear HAM Repeater List") + " (" + locator + ")"
            }
        }

        ScrollBar.vertical: ScrollBar {}

        model: rb

        delegate: RepeaterItem {}

        // Show a placeholder when no repeater is in the list so far
        Label {
            id: placeholder
            text: settings.rbActive ? qsTr("Waiting for position and repeaters") : qsTr("Hear HAM Repeater List disabled")

            anchors.margins: 60
            anchors.fill: parent

            opacity: 0.5
            visible: rmListView.count === 0

            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            wrapMode: Label.WordWrap
            font.pixelSize: 18
        }
    }
}
