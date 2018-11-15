import QtQuick 2.0
import QtQuick.Controls 2.4

CheckBox {
    id: checkbox
    checked: false

    indicator: Item {
        implicitWidth: 24
        implicitHeight: 24
        x: checkbox.leftPadding
        y: parent.height / 2 - height / 2

        Image {
            width: 24
            height: 24
            source: "qrc:/images/menu.png"
            visible: !checkbox.checked
        }

        Image {
            width: 24
            height: 24
            source: "qrc:/images/down-arrow.png"
            visible: checkbox.checked
        }
    }
}

/*##^## Designer {
    D{i:0;autoSize:true;height:960;width:640}
}
 ##^##*/
