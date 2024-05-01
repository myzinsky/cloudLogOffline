import QtQuick 2.0

//
// Used to avoid showing blurry SVG images on hDPI screens
// Taken from: https://stackoverflow.com/a/38636816
//
Item {
    property alias image: img
    property alias source: img.source
    property alias fillMode: img.fillMode
    property alias sourceSize: img.sourceSize
    property alias verticalAlignment: img.verticalAlignment
    property alias horizontalAlignment: img.horizontalAlignment

    implicitWidth: sourceSize.width
    implicitHeight: sourceSize.height

    Image {
        id: img
        anchors.centerIn: parent
        sourceSize.width: width * DevicePixelRatio
        sourceSize.height: height * DevicePixelRatio
    }
}
