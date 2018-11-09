import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

Item {
    id: root
    property alias messageText: messageText

    property string title: qsTr("About")

    Rectangle {
        anchors.fill: parent
        color: "#ffffff"
    }

    Label {
        id: versionText
        anchors.top: parent.top
        anchors.right: parent.right

        text: qsTr("Version") + ": " + versionString
        opacity: 0.6
        font.italic: true
        font.pointSize: 10
    }

    ScrollView {
        anchors.rightMargin: 20
        anchors.leftMargin: 20
        anchors.bottomMargin: 20
        anchors.topMargin: 20
        anchors.fill: parent
        clip: true
        contentWidth: parent.width - 40

        Label {
            id: messageText
            anchors.fill: parent
            text: qsTr("AboutText")
            clip: true
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
            textFormat: Text.RichText
        }
    }
}


/*##^## Designer {
    D{i:0;autoSize:true;height:960;width:640}
}
 ##^##*/
