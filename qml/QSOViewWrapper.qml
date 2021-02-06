import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

SplitView {
    id: qsoViewWrapper
    anchors.fill: parent
    orientation: Qt.Horizontal
    property string title: (addQSO || liveQSO) ? (qsTr("Add QSO") + "(" + (qsoModel.numberOfQSOs()+1) + ")") : qsTr("Edit QSO")

    property alias addQSO: qsoView.addQSO
    property alias liveQSO: qsoView.liveQSO
    property alias updateQSO: qsoView.updateQSO
    property alias rid: qsoView.rid
    property alias date: qsoView.date
    property alias time: qsoView.time
    property alias call: qsoView.call
    property alias freq: qsoView.freq
    property alias sent: qsoView.sent
    property alias recv: qsoView.recv
    property alias name: qsoView.name
    property alias ctry: qsoView.ctry
    property alias grid: qsoView.grid
    property alias qqth: qsoView.qqth
    property alias comm: qsoView.comm
    property alias ctss: qsoView.ctss
    property alias ctsr: qsoView.ctsr
    property alias sota: qsoView.sota
    property alias sots: qsoView.sots
    property alias satm: qsoView.satm
    property alias mode: qsoView.mode
    property alias satn: qsoView.mode
    property alias sync: qsoView.sync
    property alias qrzFound: qsoView.qrzFound;

    function save() {
        qsoView.save();
        title = (addQSO || liveQSO) ? (qsTr("Add QSO") + "(" + qsoModel.numberOfQSOs() + ")") : qsTr("Edit QSO");
    }

    QSOListView {
        visible: (window.width > 1000)
        width: 400
    }

    QSOView {
        id: qsoView
    }
}
