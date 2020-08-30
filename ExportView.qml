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
                highlighted: true
                Material.theme: Material.Light
                Material.accent: Material.Green

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

            Label {
                id: cabrilloContestLabel
                text: qsTr("Contest") + ":"
            }

            ComboBox {
                id: cabrilloContest
                Layout.fillWidth: true
                model: [
                    "",
                    "10-10-FALL-CW",
                    "10-10-FALL-DIGITAL",
                    "10-10-OPEN-SEASON",
                    "10-10-SPIRIT-OF-76",
                    "10-10-SPRING-CW",
                    "10-10-SPRING-DIGITAL",
                    "10-10-SPRINT",
                    "10-10-SUMMER-PHONE",
                    "10-10-WINTER-PHONE",
                    "7QP",
                    "9A-CW",
                    "AADX-CW",
                    "AADX-SSB",
                    "AGCW-QRP",
                    "AL-QSO-PARTY",
                    "ALL-AFRICA",
                    "AP-SPRINT",
                    "AR-QSO-PARTY",
                    "ARI-DX",
                    "ARRL-10",
                    "ARRL-10-GHZ",
                    "ARRL-160",
                    "ARRL-222",
                    "ARRL-DX-CW",
                    "ARRL-DX-SSB",
                    "ARRL-EME",
                    "ARRL-FD",
                    "ARRL-HPM-150",
                    "ARRL-RR-CW",
                    "ARRL-RR-DIG",
                    "ARRL-RR-PH",
                    "ARRL-RTTY",
                    "ARRL-SCR",
                    "ARRL-SS-CW",
                    "ARRL-SS-SSB",
                    "ARRL-VHF-JAN",
                    "ARRL-VHF-JUN",
                    "ARRL-VHF-SEP",
                    "AVHFC",
                    "AZ-QSO-PARTY",
                    "BALKAN-HF",
                    "BALTIC-CONTEST",
                    "BARTG-RTTY",
                    "BARTG-SPRINT",
                    "BATAVIA",
                    "BC-QSO-PARTY",
                    "BUCURESTI-DIGITAL",
                    "CA-QSO-PARTY",
                    "CANADA-DAY",
                    "CANADA-WINTER",
                    "COQP",
                    "CQ-160-CW",
                    "CQ-160-SSB",
                    "CQ-M",
                    "CQ-VHF",
                    "CQ-WPX-CW",
                    "CQ-WPX-RTTY",
                    "CQ-WPX-SSB",
                    "CQ-WW-CW",
                    "CQ-WW-RTTY",
                    "CQ-WW-SSB",
                    "CQMMDX",
                    "CVA-DX-CW",
                    "CVA-DX-SSB",
                    "CW-OPEN",
                    "CW-OPS",
                    "DARC-10",
                    "DARC-WAEDC-CW",
                    "DARC-WAEDC-RTTY",
                    "DARC-WAEDC-SSB",
                    "DE-QSO-PARTY",
                    "DL-DX-RTTY",
                    "DRCG-WW-RTTY",
                    "EA-MAJESTAD-CW",
                    "EA-MAJESTAD-SSB",
                    "EA-PSK",
                    "EARTTY",
                    "EU-PSK-DX",
                    "EUCW-160",
                    "EUHFC",
                    "EURASIA-CHAMP",
                    "F9AA-CW",
                    "F9AA-DIGI",
                    "F9AA-SSB",
                    "FCG-FQP",
                    "FT8-RU",
                    "GA-QSO-PARTY",
                    "HA-DX",
                    "HELVETIA",
                    "HI-QSO-PARTY",
                    "HOLYLAND",
                    "IAQP",
                    "IARU-HF",
                    "ID-QSO-PARTY",
                    "IL-QSO-PARTY",
                    "IN-QSO-PARTY",
                    "ISLAND-QSO-PARTY",
                    "JARTS-WW-RTTY",
                    "JIDX-CW",
                    "JIDX-SSB",
                    "KANHAM",
                    "KCJ-TOPBAND",
                    "KS-QSO-PARTY",
                    "KYQP",
                    "LA-QSO-PARTY",
                    "LZ-DX",
                    "MAKROTHEN-RTTY",
                    "MDC-QSO-PARTY",
                    "ME-QSO-PARTY",
                    "MI-QSO-PARTY",
                    "MMC-HF-CW",
                    "MN-QSO-PARTY",
                    "MO-QSO-PARTY",
                    "MRRC-OHQP",
                    "MS-QSO-PARTY",
                    "NA-SPRINT-CW",
                    "NA-SPRINT-RTTY",
                    "NA-SPRINT-SSB",
                    "NAQP-CW",
                    "NAQP-RTTY",
                    "NAQP-SSB",
                    "NC-QSO-PARTY",
                    "NCCC-SPRINT-CW",
                    "NCCC-SPRINT-RTTY",
                    "ND-QSO-PARTY",
                    "NE-QSO-PARTY",
                    "NEQP",
                    "NH-QSO-PARTY",
                    "NJQP",
                    "NM-QSO-PARTY",
                    "NRAU-10",
                    "NV-QSO-PARTY",
                    "NYQP",
                    "OCEANIA-DX-CW",
                    "OCEANIA-DX-SSB",
                    "OK-DX-RTTY",
                    "OK-OM-DX",
                    "OK-QSO-PARTY",
                    "ON-QSO-PARTY",
                    "PA-QSO-PARTY",
                    "PACC",
                    "POC",
                    "PORTUGAL-DAY",
                    "RADIO-160",
                    "RADIO-ONY",
                    "RADIO-WW-RTTY",
                    "RAEM",
                    "RCC-CUP",
                    "RDAC",
                    "RDXC",
                    "REF-CW",
                    "REF-SSB",
                    "RSGB-160",
                    "RSGB-80M-AUT",
                    "RSGB-80M-CC",
                    "RSGB-AFS-CW",
                    "RSGB-COMMONWEALTH",
                    "RSGB-DX",
                    "RSGB-FT4",
                    "RSGB-HQP",
                    "RSGB-IOTA",
                    "RSGB-LOW-POWER",
                    "RSGB-NFD",
                    "RSGB-ROLO",
                    "RTTYOPS-WEEKEND-SPRINT",
                    "RTTYOPS-WEEKSPRINT",
                    "RTTYOPS-WW-RTTY",
                    "RUS-WW-DIGI",
                    "RUS-WW-MM",
                    "RUS-WW-PSK",
                    "SA10M",
                    "SAC-CW",
                    "SAC-SSB",
                    "SARTG-NY-RTTY",
                    "SARTG-RTTY",
                    "SC-QSO-PARTY",
                    "SDQSOP",
                    "SPDX",
                    "SPDXC",
                    "SPDXC-RTTY",
                    "STAYHOME",
                    "STEW-PERRY",
                    "TARA-RTTY",
                    "TESLA-HF",
                    "TISZACUP",
                    "TN-QSO-PARTY",
                    "TRC-DX",
                    "TXQP",
                    "UBA-DX-CW",
                    "UBA-DX-SSB",
                    "UBA-ON-2M",
                    "UBA-ON-6M",
                    "UBA-ON-CW",
                    "UBA-ON-SSB",
                    "UBA-PSK63-PREFIX",
                    "UBA-SPRING-CONTEST",
                    "UKEI-DX",
                    "UKEICC-80M",
                    "UKR-CHAMP-RTTY",
                    "UKRAINIAN-DX",
                    "UN-DX",
                    "UR-DX-DIGI",
                    "UR-DX-RTTY",
                    "VA-QSO-PARTY",
                    "VKSHIRES",
                    "VOLTA-RTTY",
                    "VT-QSO-PARTY",
                    "WA-SALMON-RUN",
                    "WAG",
                    "WAPC-DX",
                    "WFD",
                    "WIQP",
                    "WVQP",
                    "WW-DIGI",
                    "WW-PMC",
                    "WWSA",
                    "WWSAC",
                    "XE-RTTY",
                    "XMAS",
                    "YARC-QSO-PARTY",
                    "YB-DX-CONTEST",
                    "YL-OM",
                    "YUDX",
                ]
            }

            Label {
                text: qsTr("Assisted") + ":"
            }

            ComboBox {
                id: cabrilloAssisted
                Layout.fillWidth: true
                model: [
                    "",
                    "ASSISTED",
                    "NON-ASSISTED",
                ]
            }

            Label {
                text: qsTr("Band") + ":"
            }

            ComboBox {
                id: cabrilloBand
                Layout.fillWidth: true
                model: [
                    "",
                    "ALL",
                    "160M",
                    "80M",
                    "40M",
                    "20M",
                    "15M",
                    "10M",
                    "6M",
                    "4M",
                    "2M",
                    "222",
                    "432",
                    "902",
                    "1.2G",
                    "2.3G",
                    "3.4G",
                    "5.7G",
                    "10G",
                    "24G",
                    "47G",
                    "75G",
                    "123G",
                    "134G",
                    "241G",
                    "Light",
                    "VHF-3-BAND",
                    "VHF-FM-ONLY",
                ]
            }

            Label {
                text: qsTr("Mode") + ":"
            }

            ComboBox {
                id: cabrilloMode
                Layout.fillWidth: true
                model: [
                    "",
                    "CW",
                    "DIGI",
                    "FM",
                    "RTTY",
                    "SSB",
                    "MIXED",
                ]
            }

            Label {
                text: qsTr("Operator") + ":"
            }

            ComboBox {
                id: cabrilloOperator
                Layout.fillWidth: true
                model: [
                    "",
                    "SINGLE-OP",
                    "MULTI-OP",
                    "CHECKLOG",
                ]
            }

            Label {
                text: qsTr("Power") + ":"
            }

            ComboBox {
                id: cabrilloPower
                Layout.fillWidth: true
                model: [
                    "",
                    "HIGH",
                    "LOW",
                    "QRP",
                ]
            }

            Label {
                text: qsTr("Station") + ":"
            }

            ComboBox {
                id: cabrilloStation
                Layout.fillWidth: true
                model: [
                    "",
                    "FIXED",
                    "MOBILE",
                    "PORTABLE",
                    "ROVER",
                    "ROVER-LIMITED",
                    "ROVER-UNLIMITED",
                    "EXPEDITION",
                    "HQ",
                    "SCHOOL",
                ]
            }

            Label {
                text: qsTr("Time") + ":"
            }

            ComboBox {
                id: cabrilloTime
                Layout.fillWidth: true
                model: [
                    "",
                    "6-HOURS",
                    "12-HOURS",
                    "24-HOURS",
                ]
            }

            Label {
                text: qsTr("Transmitter") + ":"
            }

            ComboBox {
                id: cabrilloTransmitter
                Layout.fillWidth: true
                model: [
                    "",
                    "ONE",
                    "TWO",
                    "UNLIMITED",
                ]
            }

            Label {
                text: qsTr("Overlay") + ":"
            }

            ComboBox {
                id: cabrilloOverlay
                Layout.fillWidth: true
                model: [
                    "",
                    "CLASSIC",
                    "ROOKIE",
                    "TB-WIRES",
                    "NOVICE-TECH",
                    "OVER-50",
                ]
            }

            Label {
                text: qsTr("Certificate") + ":"
            }

            ComboBox {
                id: cabrilloCertificate
                Layout.fillWidth: true
                model: [
                    "",
                    "YES",
                    "NO",
                ]
            }

            Label {
                text: qsTr("Claimed Score") + ":"
            }

            TextField {
                id: cabrilloScore
                Layout.fillWidth: true
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }

            Label {
                text: qsTr("Club") + ":"
            }

            TextField {
                id: cabrilloClub
                Layout.fillWidth: true
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }


            Label {
                text: qsTr("Email") + ":"
            }

            TextField {
                id: cabrilloEmail
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Grid Locator") + ":"
            }

            TextField {
                id: cabrilloLocator
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Location") + ":"
            }

            TextField {
                id: cabrilloLocation
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Name") + ":"
            }

            TextField {
                id: cabrilloName
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Address") + ":"
            }

            TextField {
                id: cabrilloAddress
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Operators") + ":"
            }

            TextField {
                id: cabrilloOperators
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Soapbox") + ":"
            }

            TextField {
                id: cabrilloSoapbox
                Layout.fillWidth: true
            }


            IconButton {
                id: cabrilloExport
                buttonIcon: "\uf15c"
                text: "Export Cabrillo"
                Layout.fillWidth: true
                Layout.columnSpan: 2
                highlighted: true
                Material.theme: Material.Light
                Material.accent: Material.Green

                onClicked: {
                    shareUtils.shareCabrillo(
                                cabrilloContest.currentText,
                                cabrilloAssisted.currentText,
                                cabrilloBand.currentText,
                                cabrilloMode.currentText,
                                cabrilloOperator.currentText,
                                cabrilloPower.currentText,
                                cabrilloStation.currentText,
                                cabrilloTime.currentText,
                                cabrilloTransmitter.currentText,
                                cabrilloOverlay.currentText,
                                cabrilloCertificate.currentText,
                                cabrilloScore.text,
                                cabrilloClub.text,
                                cabrilloEmail.text,
                                cabrilloLocator.text,
                                cabrilloLocation.text,
                                cabrilloName.text,
                                cabrilloAddress.text,
                                cabrilloOperators.text,
                                cabrilloSoapbox.text
                                )
                }
            }

            ExportHeader {
                icon: "\uf6dd"
                text: "CSV"
                helpText: ""
                Layout.columnSpan: 2
            }

            IconButton {
                id: csvExport
                buttonIcon: "\uf6dd"
                text: "Export CSV"
                Layout.fillWidth: true
                Layout.columnSpan: 2
                highlighted: true
                Material.theme: Material.Light
                Material.accent: Material.Green

                onClicked: {
                    shareUtils.shareCSV()
                }
            }
        }
    }
}
