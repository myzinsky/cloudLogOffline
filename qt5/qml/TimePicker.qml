import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12

Popup {
    id: timePickerPopup

    property string selectedTime

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    contentWidth: grid.implicitWidth
    contentHeight: grid.implicitHeight

    Overlay.modal: Rectangle {
        color: "#CCCCCCCC"
    }

    function zeroPad(num, places) {
        return String(num).padStart(places, '0');
    }

    Component {
        id: delegateComponent

        Label {
            text: zeroPad(modelData, 2)
            opacity: 1.0 - Math.abs(Tumbler.displacement) / (Tumbler.tumbler.visibleItemCount / 2)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }


    Control {
        id: frame

        ColumnLayout {
            id: grid
            anchors.fill: parent

            Row {
                id: row

                Tumbler {
                    id: hoursTumbler
                    model: 24
                    delegate: delegateComponent
                }

                Text {
                    height: hoursTumbler.height
                    text: ":"
                    color: "white"
                    verticalAlignment: Text.AlignVCenter
                }

                Tumbler {
                    id: minutesTumbler
                    model: 60
                    delegate: delegateComponent
                }
            }

            Button {
                text: "OK"
                Layout.fillWidth: true
                onClicked: {
                    var hours = hoursTumbler.currentIndex;
                    var minutes = minutesTumbler.currentIndex;

                    selectedTime = zeroPad(hours,2) + ":" + zeroPad(minutes,2)
                    timePickerPopup.close()
                }
            }
        }
    }

    onOpened: {
        var now = new Date();
        var utc = new Date(now.getTime() + now.getTimezoneOffset() * 60000);
        var hours = Qt.formatDateTime(utc, "HH");
        var minutes = Qt.formatDateTime(utc, "mm");

        hoursTumbler.currentIndex = hours
        minutesTumbler.currentIndex = minutes
    }
}
