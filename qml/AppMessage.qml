import QtQuick
import QtQuick.Controls

// The app's message box, drawn by the app itself. It replaces Qt.labs.platform's MessageDialog,
// whose native macOS dialog never opens with Qt 6.11: every message, help text and "are you
// sure?" in the app silently did nothing on a Mac. Same use as before: title, text, open(),
// onAccepted; "question: true" gives Yes / No instead of OK.
Dialog {
    property alias text: body.text
    property bool question: false

    parent: Overlay.overlay
    anchors.centerIn: parent
    width: Math.min(parent ? parent.width - 40 : 420, 480)
    modal: true
    standardButtons: question ? (Dialog.Yes | Dialog.No) : Dialog.Ok

    Label {
        id: body
        width: parent.width
        wrapMode: Text.WordWrap
    }
}
