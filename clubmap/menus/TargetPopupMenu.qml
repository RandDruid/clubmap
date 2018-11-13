import QtQuick 2.11
import QtQuick.Controls 2.4

Menu {
    property int currentTarget
    property int targetsCount
    signal itemClicked(string item)

    Action {
        text: qsTr("Info")
        onTriggered: itemClicked("getTargetInfo")
    }

//    Action {
//        text: qsTr("Coordinates")
//        onTriggered: itemClicked("getTargetCoordinate")
//    }

    MenuSeparator { }

    Menu {
        title: qsTr("Navigation") + "..."

        Action {
            text: qsTr("Yandex.Maps browser")
            onTriggered: itemClicked("yandexMapsBrowser")
        }

        Action {
            text: qsTr("Yandex.Maps app")
            onTriggered: itemClicked("yandexMapsApp")
        }

        Action {
            text: qsTr("Yandex.Navi app")
            onTriggered: itemClicked("yandexNaviApp")
        }

        Action {
            text: qsTr("Google.Maps")
            onTriggered: itemClicked("googleMapsBrowser")
        }
    }

    function update() {
    }
}
