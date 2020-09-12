import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import QtQuick.Extras 1.4
import QtQuick.Controls.Material 2.4
import QtQuick.Controls 1.4
import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import Qt.labs.calendar 1.0
import QtQuick.Controls.Material 2.2

Page {

    Button {
        id: datePickerButton
        text: "Date Picker"
        onClicked: {
            datePicker.open()
        }
    }

}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
