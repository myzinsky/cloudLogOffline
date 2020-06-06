import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1

Page {
    id: qsoListView
    title: qsTr("About")
    anchors.fill: parent
    anchors.margins: 10

    Label {
        text: qsTr("About")
        Layout.fillWidth: true
    }
}
