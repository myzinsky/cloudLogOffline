import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import Qt.labs.calendar 1.0
import de.webappjung 1.0

Popup {
    id: datePickerPopup

    property string selectedDate

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    Overlay.modal: Rectangle {
        color: "#CCCCCCCC"
    }

    Component.onCompleted: {
        var now = new Date();
        var utc = new Date(now.getTime() + now.getTimezoneOffset() * 60000);
        mg.month = utc.getMonth()
        mg.year = utc.getFullYear()
    }

    GridLayout {
        columns: 1

        GridLayout {
            //anchors.fill: parent
            columns: 3

            ToolButton {
                id: leftButton
                text: "\uf0a8"
                font.family: fontAwesome.name
                font.pixelSize: Qt.application.font.pixelSize * 1.6
                onClicked: {
                    if (mg.month != Calendar.January) {
                        mg.month = mg.month - 1;
                    } else {
                        mg.year = mg.year - 1;
                        mg.month = Calendar.December;
                    }
                }
            }

            Label {
                text: mg.title
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                color: "white"
            }

            ToolButton {
                id: rightButton
                text: "\uf0a9"
                font.family: fontAwesome.name
                font.pixelSize: Qt.application.font.pixelSize * 1.6
                onClicked: {
                    if (mg.month != Calendar.December) {
                        mg.month = mg.month + 1
                    } else {
                        mg.year = mg.year + 1;
                        mg.month = Calendar.January;
                    }
                }
            }
        }

        GridLayout {
            columns: 1

            DayOfWeekRow {
                locale: mg.locale
                Layout.fillWidth: true
                delegate: Text {
                    text: shortName
                    font.bold: true
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    property string shortName
                    font.pointSize: 16
                }

            }

            MonthGrid {
                id: mg
                month: Calendar.December
                year: 2015
                locale: settings.language === "German"   ? Qt.locale("de_DE") :
                        settings.language === "Armenian" ? Qt.locale("hy_AM") :
                                                           Qt.locale("en_US") ;

                Layout.fillWidth: true
                Layout.fillHeight: true

                delegate: Text {
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: model.day
                    font.bold: model.today
                    color: model.month === mg.month ? "white" : "gray"
                    font.pointSize: 16
                }

                onClicked: function (date) {
                    selectedDate = date.toISOString()
                    datePickerPopup.close();
                }
            }
        }
    }
}
