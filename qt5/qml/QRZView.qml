import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt.labs.platform 1.1

Page {
    id: page
    title: call
    anchors.margins: 5

    property string call

    Component.onCompleted: {
        qrz.lookupCall(call)
    }

    MessageDialog {
        id: qrzMessage
        buttons: StandardButton.Ok
    }

    Connections{
        target: qrz
        onQrzDone: {
            imageField.source  = image;
            nameLabel.text     = fname + " " + name;
            addr1Label.text    = addr1;
            addr2Label.text    = addr2 + ", " + zip;
            countryLabel.text  = country;
            qslmgrLabel.text   = qslmgr;
            gridLabel.text     = locator;
            latLabel.text      = lat;
            lonLabel.text      = lon;
            classLabel.text    = license;
            cqLabel.text       = cqzone;
            ituLabel.text      = ituzone;
            bornLabel.text     = born;
        }

        onQrzFail: {
            // Try it again in case the key is old ...
            if(error == "Session Timeout") {
                qrz.receiveKey();
                qrz.lookupCall(call);
            } else {
                qrzMessage.text = error;
                qrzMessage.open();
            }
        }
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: -1

        GridLayout {
            columns: 1

            Rectangle {
                implicitWidth: page.width
                implicitHeight: grid.implicitHeight
                color: "#555555"
                GridLayout {
                    id: grid
                    width: page.width // Important
                    flow:  page.width > 400 ? GridLayout.LeftToRight : GridLayout.TopToBottom


                    Image {
                        sourceSize.width: page.width > 400 ? 200 : page.width
                        width: page.width > 400 ? 200 : page.width
                        fillMode: Image.PreserveAspectFit
                        id: imageField
                    }

                    GridLayout {
                        id: infoGrid
                        Layout.fillWidth: true
                        columns: 1


                        Label {
                            id: nameLabel
                            font.weight: Font.Bold
                            font.pixelSize: 20
                            Layout.fillWidth: true
                        }

                        Label {
                            id: addr1Label
                            Layout.fillWidth: true
                        }

                        Label {
                            id: addr2Label
                            Layout.fillWidth: true
                        }

                        Label {
                            id: countryLabel
                            Layout.fillWidth: true
                        }

                        Label {
                            Layout.fillWidth: true
                            text: " "
                        }

                        Label {
                            id: qslmgrLabel
                            Layout.fillWidth: true
                            wrapMode: Label.WordWrap
                        }
                    }
                }
            }

            GridLayout {
                id: gridRest
                width: page.width // Important
                columns: 2


                Label {
                    text: qsTr("Born") + ":"
                }

                Label {
                    id: bornLabel
                    Layout.fillWidth: true
                }

                Label {
                    text: qsTr("Grid") + ":"
                }

                Label {
                    id: gridLabel
                    Layout.fillWidth: true
                }


                Label {
                    text: qsTr("Latitude") + ":"
                }

                Label {
                    id: latLabel
                    Layout.fillWidth: true
                }

                Label {
                    text: qsTr("Longitude") + ":"
                }

                Label {
                    id: lonLabel
                    Layout.fillWidth: true
                }

                Label {
                    text: qsTr("Class") + ":"
                }

                Label {
                    id: classLabel
                    Layout.fillWidth: true
                }

                Label {
                    text: qsTr("CQ Zone") + ":"
                }

                Label {
                    id: cqLabel
                    Layout.fillWidth: true
                }

                Label {
                    text: qsTr("ITU Zone") + ":"
                }

                Label {
                    id: ituLabel
                    Layout.fillWidth: true
                }
            }
        }
    }
}

