import QtQuick 2.12
import QtQuick.Controls 1.6 // for SplitView in Qt 5.12
import QtQuick.Layouts 1.12

SplitView {
    id: qsoViewWrapper
    orientation: Qt.Horizontal

    property string title: (addQSO || liveQSO) ? (qsTr("Add QSO") + " (" + (qsoModel.numberOfQSOs()) + ")") : qsTr("Edit QSO")

    property alias addQSO: qsoView.addQSO
    property alias liveQSO: qsoView.liveQSO
    property alias updateQSO: qsoView.updateQSO
    property alias repeaterQSO: qsoView.repeaterQSO
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
    property alias wwff: qsoView.wwff
    property alias wwfs: qsoView.wwfs
    property alias satm: qsoView.satm
    property alias mode: qsoView.mode
    property alias satn: qsoView.satn
    property alias propmode: qsoView.propmode
    property alias rxfreq: qsoView.rxfreq
    property alias sync: qsoView.sync
    property alias qrzFound: qsoView.qrzFound;

    function save() {
        qsoView.save();
    }

    Connections{
        target: qsoModel

        function onUpdateNumberOfQSOs(number) {
            qsoViewWrapper.title = (addQSO || liveQSO) ? (qsTr("Add QSO") + " (" + number + ")") : qsTr("Edit QSO")
        }
    }

    QSOListView {
        visible: (window.width > 1000)
        Layout.minimumWidth: 400
    }

    QSOView {
        id: qsoView
        focus: true
    }
}
