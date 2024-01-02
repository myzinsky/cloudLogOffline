import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0

ItemDelegate {

    // Do not allow user to click spacers and separators
    enabled: !isSeparator(index)

    // Alias to parent list view
    property ListModel model
    property ListView pageSelector

    height: {
        if(!isSeparator(index)) {
            return 48
        } else {
            // We assume only one Separator here:
            return Math.max (8, pageSelector.height - (model.count-1)*48)
        }
    }

    // Returns true if \c link is defined and is equal to \c true
    function isLink (index) {
        if (typeof (model.get (index).link) !== "undefined")
            return model.get (index).link

        return false
    }

    // Returns true if \c separator is defiend and is equal to \c true
    function isSeparator (index) {
        if (typeof (model.get (index).separator) !== "undefined")
            return model.get (index).separator

        return false
    }

    // Returns the icon for the drawer item
    function iconSource (index) {
        if (typeof (model.get (index).pageIcon) !== "undefined")
            return model.get (index).pageIcon

        return ""
    }

    // Returns the title for the drawer item
    function itemText (index) {
        if (typeof (model.get (index).pageTitle) !== "undefined")
            return model.get (index).pageTitle

        return ""
    }

    // Decide if we should highlight the item
    highlighted: ListView.isCurrentItem ? !isLink (index) : false

    // Layout
    RowLayout {
        spacing: 16
        anchors.fill: parent
        Layout.fillHeight: true
        visible: !isSeparator(index)

        Label {
            id: labelIcon
            font.family: fontAwesome.name
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            opacity: 0.87
            text: iconSource (index)
            font.weight: Font.Medium
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Layout.leftMargin: Math.max(window.notchLeft, window.notchRight) + 16
        }

        Label {
            opacity: 0.87
            font.pixelSize: 14
            text: itemText (index)
            font.weight: Font.Medium
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
        }
    }
}
