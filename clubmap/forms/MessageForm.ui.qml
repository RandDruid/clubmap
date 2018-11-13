import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

Item {
    property alias messageText: messageText

    property string title
    property string message
    property string imageUrl

    Rectangle {
        anchors.fill: parent
        color: "#ffffff"
    }

    Item {
        anchors.rightMargin: 20
        anchors.leftMargin: 20
        anchors.bottomMargin: 20
        anchors.topMargin: 20
        anchors.fill: parent

        ColumnLayout {
            id: columnLayout1
            spacing: 20
            anchors.fill: parent

            Image {
                id: messageImage
                Layout.alignment: Qt.AlignHCenter
                source: imageUrl
                visible: imageUrl
            }

            Label {
                id: messageText
                text: message
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
            }
        }
    }
}


/*##^## Designer {
    D{i:0;autoSize:true;height:960;width:640}
}
 ##^##*/
