import QtQuick 2.11
import QtQuick.Controls 2.4
import QtLocation 5.11
import QtPositioning 5.11

Map {
    id: map

    property variant markers
    property variant targets
    property variant mapItems
    property int markerCounter: 0 // counter for total amount of markers. Resets to 0 when number of markers = 0
    property int targetCounter: 0 // counter for total amount of targets. Resets to 0 when number of markers = 0
    property int currentMarker
    property int currentTarget
    property int lastX : -1
    property int lastY : -1
    property int pressX : -1
    property int pressY : -1
    property int jitterThreshold : 30
    property bool followme: false
    property bool reportGps: false
    property variant scaleLengths: [5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000, 100000, 200000, 500000, 1000000, 2000000]

    signal coordinatesCaptured(double latitude, double longitude)
    signal showMainMenu(variant coordinate)
    signal showTargetMenu(variant coordinate)
    signal showPointMenu(variant coordinate)
    signal boxChanged(double longitudeMin, double longitudeMax, double latitudeMin, double latitudeMax)

    function formatDistance(meters)
    {
        var dist = Math.round(meters)
        if (dist > 1000 ){
            if (dist > 100000){
                dist = Math.round(dist / 1000)
            }
            else{
                dist = Math.round(dist / 100)
                dist = dist / 10
            }
            dist = qsTr("%1 km").arg(dist)
        }
        else{
            dist = qsTr("%1 m").arg(dist)
        }
        return dist
    }

    function calculateScale() {
        var coord1, coord2, dist, text, f
        f = 0
        coord1 = map.toCoordinate(Qt.point(0, scale.y))
        coord2 = map.toCoordinate(Qt.point(0 + scaleImage.sourceSize.width, scale.y))
        dist = Math.round(coord1.distanceTo(coord2))

        if (dist === 0) {
            // not visible
        } else {
            for (var i = 0; i < scaleLengths.length - 1; i++) {
                if (dist < (scaleLengths[i] + scaleLengths[i + 1]) / 2 ) {
                    f = scaleLengths[i] / dist
                    dist = scaleLengths[i]
                    break;
                }
            }
            if (f === 0) {
                f = dist / scaleLengths[i]
                dist = scaleLengths[i]
            }
        }

        text = formatDistance(dist)
        scaleImage.width = (scaleImage.sourceSize.width * f) - 2 * scaleImageLeft.sourceSize.width
        scaleText.text = text

        coord1 = map.toCoordinate(Qt.point(0, 0))
        coord2 = map.toCoordinate(Qt.point(map.width, map.height))
        boxChanged(coord1.longitude, coord2.longitude, coord2.latitude, coord1.latitude)
    }

    function deleteMarkers() {
        var count = map.markers.length
        for (var i = 0; i < count; i++) {
            map.removeMapItem(map.markers[i])
            map.markers[i].destroy()
        }
        map.markers = []
        markerCounter = 0
    }

    function deleteTargets() {
        var count = map.targets.length
        for (var i = 0; i < count; i++) {
            map.removeMapItem(map.targets[i])
            map.targets[i].destroy()
        }
        map.targets = []
        targetCounter = 0
    }

    function deleteMapItems() {
        var count = map.mapItems.length
        for (var i = 0; i < count; i++) {
            map.removeMapItem(map.mapItems[i])
            map.mapItems[i].destroy()
        }
        map.mapItems = []
    }

    function addMarker() {
        var count = map.markers.length
        markerCounter++
        var marker = Qt.createQmlObject ('Marker {}', map)
        map.addMapItem(marker)
        marker.z = map.z + 1
        marker.coordinate = mouseArea.lastCoordinate

        //update list of markers
        var myArray = []
        for (var i = 0; i<count; i++){
            myArray.push(markers[i])
        }
        myArray.push(marker)
        markers = myArray
    }

    function addTarget(latitude, longitude, icon, title, userid) {
        var count = map.targets.length
        targetCounter++
        var target = Qt.createQmlObject ('Target {icon: ' + icon + '; title:"' + title +'"; userid: ' + userid + '}', map)
        map.addMapItem(target)
        target.z = map.z + 1
        target.coordinate = QtPositioning.coordinate(latitude, longitude);

        //update list of targets
        var myArray = []
        for (var i = 0; i < count; i++){
            myArray.push(targets[i])
        }
        myArray.push(target)
        targets = myArray
    }

    function addGeoItem(item) {
        var count = map.mapItems.length
        var co = Qt.createComponent(item + '.qml')
        if (co.status === Component.Ready) {
            var o = co.createObject(map)
            o.setGeometry(map.markers, currentMarker)
            map.addMapItem(o)

            //update list of items
            var myArray = []
            for (var i = 0; i < count; i++){
                myArray.push(mapItems[i])
            }
            myArray.push(o)
            mapItems = myArray

        } else {
            console.log(item + " is not supported.")
        }
    }

    function deleteMarker(index) {
        //update list of markers
        var myArray = []
        var count = map.markers.length
        for (var i = 0; i < count; i++){
            if (index !== i) myArray.push(map.markers[i])
        }

        map.removeMapItem(map.markers[index])
        map.markers[index].destroy()
        map.markers = myArray
        if (markers.length === 0) markerCounter = 0
    }

    zoomLevel: (maximumZoomLevel - minimumZoomLevel)/2
    center {
        // Moscow city
        latitude: 55.75222
        longitude: 37.61556
    }

    // Enable pan, flick, and pinch gestures to zoom in and out
    gesture.acceptedGestures: MapGestureArea.PanGesture | MapGestureArea.FlickGesture | MapGestureArea.PinchGesture | MapGestureArea.RotationGesture | MapGestureArea.TiltGesture
    gesture.flickDeceleration: 3000
    gesture.enabled: true

    focus: true
    onCopyrightLinkActivated: Qt.openUrlExternally(link)

    onCenterChanged: {
        scaleTimer.restart()
        if (map.followme)
            if (map.center !== webMan.coordinate) map.followme = false
    }

    onZoomLevelChanged: {
        scaleTimer.restart()
        if (map.followme) map.center = webMan.coordinate
    }

    onWidthChanged: {
        scaleTimer.restart()
    }

    onHeightChanged: {
        scaleTimer.restart()
    }

    Component.onCompleted: {
        markers = [];
        targets = [];
        mapItems = [];
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_Plus) {
            map.zoomLevel++;
        } else if (event.key === Qt.Key_Minus) {
            map.zoomLevel--;
        } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Right ||
                   event.key === Qt.Key_Up   || event.key === Qt.Key_Down) {
            var dx = 0;
            var dy = 0;

            switch (event.key) {

            case Qt.Key_Left: dx = map.width / 4; break;
            case Qt.Key_Right: dx = -map.width / 4; break;
            case Qt.Key_Up: dy = map.height / 4; break;
            case Qt.Key_Down: dy = -map.height / 4; break;

            }

            var mapCenterPoint = Qt.point(map.width / 2.0 - dx, map.height / 2.0 - dy);
            map.center = map.toCoordinate(mapCenterPoint);
        }
    }

    function updatePosition(latitude, longitude) {
        if (followme) map.center = webMan.coordinate
    }

    function updateTargets(targetsStr) {
        var users = targetsStr.split(";");
        if (users.length > 2) {
            map.deleteTargets();
            users.forEach(parseTarget);
        }
    }

    function parseTarget(target) {
        var params = target.split(",");
        if (params.length > 4) {
            map.addTarget(params[2]/1000000.0, params[3]/1000000.0, params[5], params[1], params[0]);
        }
    }

    Connections {
        target: webMan
        onPositionChanged: updatePosition()
        onTargetsListChanged: updateTargets(webMan.lastTargetsStr)
    }

    Component {
        id: pointDelegate

        MapCircle {
            id: point
            radius: 1000
            color: "#46a2da"
            border.color: "#190a33"
            border.width: 2
            smooth: true
            opacity: 0.25
            center: locationData.coordinate

            MouseArea {
                anchors.fill:parent
                id: circleMouseArea
                hoverEnabled: false
                property variant lastCoordinate

                onPressed : {
                    map.lastX = mouse.x + parent.x
                    map.lastY = mouse.y + parent.y
                    map.pressX = mouse.x + parent.x
                    map.pressY = mouse.y + parent.y
                    lastCoordinate = map.toCoordinate(Qt.point(mouse.x, mouse.y))
                }

                onPositionChanged: {
                    if (Math.abs(map.pressX - parent.x- mouse.x ) > map.jitterThreshold ||
                            Math.abs(map.pressY - parent.y -mouse.y ) > map.jitterThreshold) {
                        if (pressed) parent.radius = parent.center.distanceTo(
                                         map.toCoordinate(Qt.point(mouse.x, mouse.y)))
                    }
                    if (mouse.button === Qt.LeftButton) {
                        map.lastX = mouse.x + parent.x
                        map.lastY = mouse.y + parent.y
                    }
                }

                onPressAndHold:{
                    if (Math.abs(map.pressX - parent.x- mouse.x ) < map.jitterThreshold
                            && Math.abs(map.pressY - parent.y - mouse.y ) < map.jitterThreshold) {
                        showPointMenu(lastCoordinate);
                    }
                }
            }
        }
    }

    Timer {
        id: scaleTimer
        interval: 100
        running: false
        repeat: false
        onTriggered: {
            map.calculateScale()
        }
    }

    Item {
        id: scale
        z: map.z + 3
        visible: scaleText.text !== qsTr("%1 m").arg(0)
        anchors.bottom: parent.bottom;
        anchors.right: parent.right
        anchors.margins: 20
        height: scaleText.height * 2
        width: scaleImage.width

        Image {
            id: scaleImageLeft
            source: "../images/scale_end.png"
            anchors.bottom: parent.bottom
            anchors.right: scaleImage.left
        }
        Image {
            id: scaleImage
            source: "../images/scale.png"
            anchors.bottom: parent.bottom
            anchors.right: scaleImageRight.left
        }
        Image {
            id: scaleImageRight
            source: "../images/scale_end.png"
            anchors.bottom: parent.bottom
            anchors.right: parent.right
        }
        Label {
            id: scaleText
            color: "#004EAE"
            anchors.centerIn: parent
            text: qsTr("%1 m").arg(0)
        }
        Component.onCompleted: {
            map.calculateScale();
        }
    }

    MouseArea {
        id: mouseArea
        property variant lastCoordinate
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed : {
            map.lastX = mouse.x
            map.lastY = mouse.y
            map.pressX = mouse.x
            map.pressY = mouse.y
            lastCoordinate = map.toCoordinate(Qt.point(mouse.x, mouse.y))
        }

        onPositionChanged: {
            if (mouse.button === Qt.LeftButton) {
                map.lastX = mouse.x
                map.lastY = mouse.y
            }
        }

        onDoubleClicked: {
            var mouseGeoPos = map.toCoordinate(Qt.point(mouse.x, mouse.y));
            var preZoomPoint = map.fromCoordinate(mouseGeoPos, false);
            if (mouse.button === Qt.LeftButton) {
                map.zoomLevel = Math.floor(map.zoomLevel + 1)
            } else if (mouse.button === Qt.RightButton) {
                map.zoomLevel = Math.floor(map.zoomLevel - 1)
            }
            var postZoomPoint = map.fromCoordinate(mouseGeoPos, false);
            var dx = postZoomPoint.x - preZoomPoint.x;
            var dy = postZoomPoint.y - preZoomPoint.y;

            var mapCenterPoint = Qt.point(map.width / 2.0 + dx, map.height / 2.0 + dy);
            map.center = map.toCoordinate(mapCenterPoint);

            lastX = -1;
            lastY = -1;
        }

        onPressAndHold:{
            if (Math.abs(map.pressX - mouse.x ) < map.jitterThreshold
                    && Math.abs(map.pressY - mouse.y ) < map.jitterThreshold) {
                showMainMenu(lastCoordinate);
            }
        }
    }
}
