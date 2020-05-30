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
        anchors.fill: parent
        model: qsoModel
        delegate: QSOItem {}
        anchors.margins: 5
        ScrollBar.vertical: ScrollBar {}
    }
}


