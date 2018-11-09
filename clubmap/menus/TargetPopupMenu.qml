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

    Action {
        text: qsTr("Coordinates")
        onTriggered: itemClicked("getTargetCoordinate")
    }

    function update() {
    }
}
