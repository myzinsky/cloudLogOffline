import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1

Page {
    id: page
    title: qsTr("About")
    anchors.fill: parent
    anchors.margins: 5

    ScrollView {
        id: scrollView
        anchors.fill: parent

        GridLayout {
            id: grid
            columns: 1
            width: page.width // Important


        Label {
            id: aboutCloudLogOffline
            padding: 5
            wrapMode: Text.WordWrap
            width: grid.width

            text: "<h1>About</h1>
CloudLogApp is developed by Web &amp; App Dr.-Ing. Matthias Jung (DL9MJ),<br>
http://www.webappjung.de/<br>"
            color: "white"
        }
        Label {
            id: aboutDrawer
            padding: 5
            wrapMode: Text.WordWrap
            width: grid.width
            // https://gist.github.com/alex-spataru/ee5e74f82a72a0a2e446766a77c43665<br>

            text: "<h1>Used Open Source Librarys</h1>
<hr>
<h2>QML Material Drawer by Alex-Spataru</h2><br>
<i>
THE FUCK YOU WANT TO PUBLIC LICENSE<br>
Version 2, December 2004<br><br>

Copyright (C) 2004 Sam Hocevar sam@hocevar.net <br><br>

Everyone is permitted to copy and distribute verbatim or modified<br>
copies of this license document, and changing it is allowed as long<br>
as the name is changed.<br><br>

DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE<br>
TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION<br><br>

0. You just DO WHAT THE FUCK YOU WANT TO.<br>
<hr>
</i>
               "
            color: "white"
        }
    }
}
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
