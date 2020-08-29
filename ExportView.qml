import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls.Material 2.4
import Qt.labs.settings 1.0
import Qt.labs.platform 1.1
import com.lasconic 1.0

Page {
    id: page
    anchors.fill: parent
    title: "Export"
    anchors.margins: 5

    MessageDialog {
        id: cloudLogMessage
        buttons: MessageDialog.Ok
    }

    Connections{
        target: cl

        onUploadSucessfull: {
            progressBar.value = progress
        }

        onUploadFailed: {
            cloudLogMessage.text = error
            cloudLogMessage.open
        }
    }

    ScrollView {
        anchors.fill: parent

        GridLayout {
            id: grid
            columns: 2
            width: page.width // Important

            ExportHeader {
                icon: "\uf0c2"
                text: "CloudLog"
                helpText: ""
                Layout.columnSpan: 2
            }

            ProgressBar {
                id: progressBar
                height: 10
                value: 0
                Layout.fillWidth: true
                Layout.columnSpan: 2
            }

            IconButton {
                id: cloudLogUpload
                buttonIcon: "\uf382"
                text: "Upload QSOs to Cloudlog"
                Layout.fillWidth: true
                highlighted: settings.cloudLogActive
                enabled: settings.cloudLogActive
                Material.theme: Material.Light
                Material.accent: Material.Green
                Layout.columnSpan: 2

                onClicked: {
                    cl.uploadToCloudLog(settings.cloudLogSSL,
                                        settings.cloudLogURL,
                                        settings.cloudLogKey)
                }
            }

            IconButton {
                id: cloudLogDelete
                buttonIcon: "\uf2ed"
                text: "Delete Uploaded QSOs"
                Layout.fillWidth: true
                highlighted: settings.cloudLogActive
                enabled: settings.cloudLogActive
                Material.theme: Material.Light
                Material.accent: Material.Red
                Layout.columnSpan: 2

                onClicked: {
                    cl.deleteUploadedQsos()
                    qsoModel.submit();
                    qsoModel.select()
                }
            }

            ExportHeader {
                icon: "\uf15c"
                text: "ADIF"
                helpText: ""
                Layout.columnSpan: 2
            }

            ShareUtils {
                id: shareUtils
            }

            IconButton {
                id: adifExport
                buttonIcon: "\uf15c"
                text: "Export ADIF"
                Layout.fillWidth: true
                Layout.columnSpan: 2

                onClicked: {
                    shareUtils.shareADIF()
                }
            }

            ExportHeader {
                icon: "\uf15c"
                text: "Cabrillo"
                helpText: ""
                Layout.columnSpan: 2
            }

            IconButton {
                id: cabrilloExport
                buttonIcon: "\uf15c"
                text: "Export Cabrillo"
                Layout.fillWidth: true
                Layout.columnSpan: 2

                onClicked: {
                    shareUtils.shareCabrillo()
                }
            }
        }
    }
}
