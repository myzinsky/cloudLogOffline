import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls.Material 2.4

TextField {
    EnterKey.type: Qt.EnterKeyNext
    Keys.onReturnPressed: KeyNavigation.tab.forceActiveFocus();
    Layout.fillWidth: true
}
