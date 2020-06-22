import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1

Page {
    id: page
    title: qsTr("About")
    anchors.fill: parent
    anchors.margins: 5

    ScrollView {
        anchors.fill: parent

        Text {
            id: aboutText
            padding: 20
            wrapMode: Text.WordWrap
            width: page.width // Important

            text: "<h1>About</h1>
               CloudLogApp is developed by Web &amp; App Dr.-Ing. Matthias Jung (DL9MJ),
               http://www.webappjung.de/<br>
               <h1>Used Open Source Librarys</h1>
               <ul>
               <il>
               QML Material Drawer by Alex-Spataru<br>
               https://gist.github.com/alex-spataru/ee5e74f82a72a0a2e446766a77c43665
               </il>
               </ul>
               "
            color: "white"
        }
    }
}
