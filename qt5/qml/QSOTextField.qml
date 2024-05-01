import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

TextField {
    EnterKey.type: Qt.EnterKeyNext
    Keys.onReturnPressed: KeyNavigation.tab.forceActiveFocus();
    Layout.fillWidth: true
}
