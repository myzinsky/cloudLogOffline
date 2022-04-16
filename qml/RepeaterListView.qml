import QtQuick 2.0
import QtWebSockets 1.15
import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1
import de.webappjung 1.0

Page {
    id: page
    title: qsTr("Repeater Book")
    anchors.fill: parent
    Layout.margins: 5

    Component.onCompleted:  {
    //    if(settings.bmActive) {
    //        console.log("Connect");
    //        bm.connect();
    //    }
    }

    Component.onDestruction: {
    //    if(settings.bmActive) {
    //        bm.stop();
    //    }
    }

    Connections{
    //    target: bm
    //    onConnected: {
    //        bm.start();
    //    }
    }

    ListView {
        id: rmListView
        anchors.fill: parent
        spacing: 5

        ScrollBar.vertical: ScrollBar {}

        model: rb

        delegate: RepeaterItem {}

        // Show a placeholder when no QSO is in the list so far
        Label {
            id: placeholder
            text: qsTr("Define Repeatermap Radius in Seetings")

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
