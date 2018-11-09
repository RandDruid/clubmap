import QtQuick 2.11
import QtLocation 5.11

MapQuickItem {
    id: target

    property string title: "User"
    property int icon: 0
    property int userid: 0

    property alias lastMouseX: targetMouseArea.lastX
    property alias lastMouseY: targetMouseArea.lastY

    anchorPoint.x: image.width/4
    anchorPoint.y: image.height

    sourceItem: Image {
        id: image
        width: 24
        height: 24
        source: "../images/ticon" + icon + ".png"
        opacity: targetMouseArea.pressed ? 0.6 : 1.0
        MouseArea  {
            id: targetMouseArea
            property int pressX : -1
            property int pressY : -1
            property int jitterThreshold : 10
            property int lastX: -1
            property int lastY: -1
            anchors.fill: parent
            hoverEnabled : false
            drag.target: target
            preventStealing: true

            onPressed : {
                map.pressX = mouse.x
                map.pressY = mouse.y
                map.currentTarget = -1
                for (var i = 0; i< map.targets.length; i++){
                    if (target === map.targets[i]){
                        map.currentTarget = i
                        break
                    }
                }
            }

            onPressAndHold:{
                if (Math.abs(map.pressX - mouse.x ) < map.jitterThreshold
                        && Math.abs(map.pressY - mouse.y ) < map.jitterThreshold) {
                    var p = map.fromCoordinate(target.coordinate)
                    lastX = p.x
                    lastY = p.y
                    map.showTargetMenu(target.coordinate)
                }
            }
        }

        Rectangle {
            color: "darkblue"
            opacity: 0.5
            y: image.height
            height: number.height + 4
            width: number.width + 4
            radius: 2
        }

        Text {
            id: number
            y: image.height + 2
            x: 2
            // width: image.width
            color: "white"
            font.bold: false
            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter
            Component.onCompleted: {
                text = title
            }
        }

    }

    Component.onCompleted: coordinate = map.toCoordinate(Qt.point(targetMouseArea.mouseX, targetMouseArea.mouseY));
}

/*##^## Designer {
    D{i:0;autoSize:true;height:150;width:150}
}
 ##^##*/
