import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.4
import Qt.labs.settings 1.0
import QtQuick.Window 2.12
import de.webappjung 1.0

Popup {
    id: datePickerPopup

    property alias selectedDate: cal.selectedDate

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    Overlay.modal: Rectangle {
        color: "#CCCCCCCC"
    }

    Calendar {
        id: cal

        onClicked: {
            datePickerPopup.close()
        }

        style: CalendarStyle {
            gridVisible: true
            gridColor: "#303030"

            dayDelegate: Rectangle {

                color: styleData.selected ? Material.color(Material.BlueGrey) : ((styleData.visibleMonth && styleData.valid) ? "#555555" : "#303030")

                Label {
                    text: styleData.date.getDate()
                    anchors.centerIn: parent
                    color: styleData.valid ? "white" : "grey"
                }
            }

            dayOfWeekDelegate: Rectangle {
                height: 30
                color: Material.color(Material.BlueGrey)

                Label {
                    text: styleData.dayOfWeek === 0 ? qsTr("Su") :
                          styleData.dayOfWeek === 1 ? qsTr("Mo") :
                          styleData.dayOfWeek === 2 ? qsTr("Tu") :
                          styleData.dayOfWeek === 3 ? qsTr("We") :
                          styleData.dayOfWeek === 4 ? qsTr("Th") :
                          styleData.dayOfWeek === 5 ? qsTr("Fr") :
                          styleData.dayOfWeek === 6 ? qsTr("Sa") : "";
                    anchors.centerIn: parent
                    color: "white"
                }
            }

            navigationBar: Rectangle {
                color: "#303030"
                height: leftButton.height

                GridLayout {
                    columns: 3;
                    width: cal.width

                    ToolButton {
                        id: leftButton
                        text: "\uf0a8"
                        font.family: fontAwesome.name
                        font.pixelSize: Qt.application.font.pixelSize * 1.6
                        onClicked: {
                            cal.showPreviousMonth();
                        }
                    }

                    Label {
                        text: cal.visibleMonth === 0  ? qsTr("January")   + " " + cal.visibleYear :
                              cal.visibleMonth === 1  ? qsTr("February")  + " " + cal.visibleYear :
                              cal.visibleMonth === 2  ? qsTr("March")     + " " + cal.visibleYear :
                              cal.visibleMonth === 3  ? qsTr("April")     + " " + cal.visibleYear :
                              cal.visibleMonth === 4  ? qsTr("May")       + " " + cal.visibleYear :
                              cal.visibleMonth === 5  ? qsTr("June")      + " " + cal.visibleYear :
                              cal.visibleMonth === 6  ? qsTr("July")      + " " + cal.visibleYear :
                              cal.visibleMonth === 7  ? qsTr("August")    + " " + cal.visibleYear :
                              cal.visibleMonth === 8  ? qsTr("September") + " " + cal.visibleYear :
                              cal.visibleMonth === 9  ? qsTr("October")   + " " + cal.visibleYear :
                              cal.visibleMonth === 10 ? qsTr("November")  + " " + cal.visibleYear :
                              cal.visibleMonth === 11 ? qsTr("December")  + " " + cal.visibleYear : "";
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
                            cal.showNextMonth()
                        }
                    }
                }
            }
        }
    }
}
