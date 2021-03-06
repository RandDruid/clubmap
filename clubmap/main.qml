import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import "map"
import "menus"
import "forms"

ApplicationWindow {
    id: appWindow
    visible: true
    width: 640
    height: 520
    title: qsTr("ClubMap")

    property variant map
    property variant minimap

    function roundNumber(number, digits)
    {
        var multiple = Math.pow(10, digits);
        return Math.round(number * multiple) / multiple;
    }

    function createMap(pluginName) {

        if (minimap) {
            minimap.destroy()
            minimap = null
        }

        var zoomLevel = null
        var tilt = null
        var bearing = null
        var fov = null
        var center = null
        if (map) {
            zoomLevel = map.zoomLevel
            tilt = map.tilt
            bearing = map.bearing
            fov = map.fieldOfView
            center = map.center
            map.destroy()
        }

        map = mapComponent.createObject(page);
        // map = mapComponent;

        if (pluginName === "osm") {
            map.plugin = map.pluginOSM;
        } else if (pluginName === "here") {
            map.plugin = map.pluginHERE;
        }

        if (zoomLevel != null) {
            map.tilt = tilt
            map.bearing = bearing
            map.fieldOfView = fov
            map.zoomLevel = zoomLevel
            map.center = center
        } else {
            map.zoomLevel = 11; // Math.floor((map.maximumZoomLevel - map.minimumZoomLevel)/2)
            // defaulting to 45 degrees, if possible.
            map.fieldOfView = Math.min(Math.max(45.0, map.minimumFieldOfView), map.maximumFieldOfView)
        }

        map.forceActiveFocus()
    }

    function initializeProviders(pluginName)
    {
        createMap(pluginName);
    }

    Component.onCompleted: {
        drawer.load();
    }

    header: ToolBar {
        contentHeight: 48

        Image {
            id: imageMenu
            width: 48
            height: 48
            anchors.left: parent.left
            anchors.top: parent.top
            source: stackView.depth > 1 ? "qrc:/images/left-arrow.png" : "qrc:/images/menu.png"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (stackView.depth > 1) {
                        stackView.pop()
                    } else {
                        drawer.open()
                    }
                }
            }
        }

        Label {
            id: labelTitle
            anchors.centerIn: parent
            anchors.leftMargin: 48
            visible: labelTitle.text !== ""
            text: stackView.currentItem.title ? stackView.currentItem.title : ""
        }

        Item {
            anchors.fill: parent
            anchors.leftMargin: 52

            visible: labelTitle.text === ""

            ColumnLayout {
                anchors.fill: parent
                anchors.rightMargin: 48
                anchors.topMargin: 2
                anchors.bottomMargin: 2
                spacing: 0

                Label {
                    text: webMan.statusText1
                }
//                Label {
//                    text: webMan.statusText2
//                }
                RowLayout {
                    ProgressBar {
                        from: 0
                        to: webMan.wantGetTargetsInt
                        value: webMan.wantGetTargetsBool ? (webMan.wantGetTargetsInt - webMan.statusText2.split(';')[0]) : 0

                        Rectangle {
                            anchors.fill: parent
                            visible: !webMan.wantGetTargetsBool
                            color: "red"
                        }
                    }
                    ProgressBar {
                        from: 0
                        to: webMan.wantSendPositionInt
                        value: webMan.wantSendPositionBool ? (webMan.wantSendPositionInt - webMan.statusText2.split(';')[1]) : 0

                        Rectangle {
                            anchors.fill: parent
                            visible: !webMan.wantSendPositionBool
                            color: "red"
                        }
                    }
                }
            }

            BusyIndicator {
                anchors.right: parent.right
                width: 48
                height: 48

                running: webMan.inProgress
                visible: running
            }
        }

    }

    MapPopupMenu {
        id: mapPopupMenu

        function show(coordinate) {
            stackView.pop(page)
            mapPopupMenu.coordinate = coordinate
            mapPopupMenu.markersCount = map.markers.length
            mapPopupMenu.mapItemsCount = map.mapItems.length
            mapPopupMenu.update()
            mapPopupMenu.popup()
        }

        onItemClicked: {
            stackView.pop(page)
            switch (item) {
            case "getCoordinate":
                map.coordinatesCaptured(coordinate.latitude, coordinate.longitude)
                break
            default:
                console.log("Unsupported operation")
            }
        }
    }

    TargetPopupMenu {
        id: targetPopupMenu

        property string textInfo: qsTr("InfoText")

        function show(coordinate) {
            stackView.pop(page)
            targetPopupMenu.targetsCount = map.targets.length
            targetPopupMenu.update()
            targetPopupMenu.popup()
        }

        onItemClicked: {
            stackView.pop(page)
            var coord1 = webMan.coordinate;
            var coord2 = map.targets[map.currentTarget].coordinate;
            var url;
            switch (item) {
                case "getTargetInfo":
                    stackView.showMessage(
                                map.targets[map.currentTarget].title,
                                textInfo
                                    .arg(forumBaseUrl)
                                    .arg(map.targets[map.currentTarget].userid)
                                    .arg(coord2.latitude)
                                    .arg(coord2.longitude),
                                "%1mobiquo/avatar.php?user_id=%2"
                                    .arg(forumBaseUrl)
                                    .arg(map.targets[map.currentTarget].userid)
                                );
                    break;
                case "getTargetCoordinate":
                    map.coordinatesCaptured(coord2.latitude, coord2.longitude)
                    break;
                case "yandexMapsBrowser":
                    url = "https://maps.yandex.ru/?rtext=" +
                            roundNumber(coord1.latitude, 6) + "," + roundNumber(coord1.longitude, 6) + "~" +
                            roundNumber(coord2.latitude, 6) + "," + roundNumber(coord2.longitude, 6) +
                            "&rtt=auto"
                    Qt.openUrlExternally(url);
                    break;
                case "yandexMapsApp":
                    url = "yandexmaps://maps.yandex.ru/?rtext=" +
                            roundNumber(coord1.latitude, 6) + "," + roundNumber(coord1.longitude, 6) + "~" +
                            roundNumber(coord2.latitude, 6) + "," + roundNumber(coord2.longitude, 6) +
                            "&rtt=auto"
                    Qt.openUrlExternally(url);
                    break;
                case "yandexNaviApp":
                    url = "yandexnavi://build_route_on_map?" +
                    //        "lat_from=" + roundNumber(coord1.latitude, 6) + "&long_from=" + roundNumber(coord1.longitude, 6) + "&" +
                            "lat_to=" + roundNumber(coord2.latitude, 6) + "&long_to=" + roundNumber(coord2.longitude, 6)
                    Qt.openUrlExternally(url);
                    break;
                case "googleMapsBrowser":
                    url = "https://www.google.com/maps/dir/?api=1&origin=" +
                            roundNumber(coord1.latitude, 6) + "," + roundNumber(coord1.longitude, 6) + "&destination=" +
                            roundNumber(coord2.latitude, 6) + "," + roundNumber(coord2.longitude, 6)
                    Qt.openUrlExternally(url);
                    break;
                default:
                    console.log("Unsupported operation")
            }
        }
    }

    MessageForm {
        id: messageForm
        messageText.onLinkActivated: Qt.openUrlExternally(link)
    }

    AboutForm {
        id: aboutForm
        messageText.onLinkActivated: Qt.openUrlExternally(link)
    }

    Drawer {
        id: drawer

        width: 360
        height: appWindow.height

        property bool isFollowMe: false;
        property bool isMiniMap: false;
        property variant component

        onOpened: {
            mainDrawer.adjustIcon();
        }

        onClosed: {
            mainDrawer.save();
            webMan.saveSettings();
        }

        function finishCreation() {
            if (component.status === Component.Ready) {
                minimap = component.createObject(map);
                if (minimap === null) {
                    // Error Handling
                    console.log("Error creating object");
                }
            } else if (component.status === Component.Error) {
                // Error Handling
                console.log("Error loading component:", component.errorString());
            }
            isMiniMap = minimap
        }

        function toggleMiniMapState()
        {
            if (minimap) {
                minimap.destroy()
                minimap = null
            } else {
                component = Qt.createComponent("map/MiniMap.qml");
                if (component.status === Component.Ready)
                    finishCreation();
                else
                    component.statusChanged.connect(finishCreation);
            }
        }

        function load() {
            mainDrawer.load();
        }

        MainDrawer {
            id: mainDrawer
            anchors.fill: parent

            isFollowMe: isFollowMe
            isMiniMap: isMiniMap
            wantSendPositionInt: webMan.wantSendPositionInt
            wantSendPositionBool: webMan.wantSendPositionBool
            wantGetTargetsInt: webMan.wantGetTargetsInt
            wantGetTargetsBool: webMan.wantGetTargetsBool
            isPositionLive: webMan.positionLive
            fixedPositionLatitude: fixedPositionSource.latitude
            fixedPositionLongitude: fixedPositionSource.longitude
            iconId: webMan.iconId
            selectedLanguage: webMan.language
            selectedMapType: webMan.mapType


            onChangeWantSendPositionInt: {
                webMan.changeWantSendPositionInt(newValue);
            }

            onChangeWantSendPositionBool: {
                webMan.changeWantSendPositionBool(newValue);
            }

            onChangeWantGetTargetsInt: {
                webMan.changeWantGetTargetsInt(newValue);
            }

            onChangeWantGetTargetsBool: {
                webMan.changeWantGetTargetsBool(newValue);
            }

            onChangePositionSource: {
                webMan.changePositionSource(online);
            }

            onChangeFixedPosition: {
                fixedPositionSource.setPosition(latitude, longitude);
                drawer.close();
            }

            onChangeIcon: {
                webMan.changeIcon(newValue);
            }

            onRecreateMap: {
                createMap(mapType);
            }

            onMenuTriggered: {
                switch (item) {
                    case "minimap": stackView.pop(page); drawer.toggleMiniMapState(); drawer.close(); break;
                    case "followme": stackView.pop(page); map.followme = !map.followme; drawer.close(); break;
                    case "about": stackView.push(aboutForm); drawer.close(); break;
                    case "back": drawer.close(); break;
                    default: break;
                }
            }
        }
    }

    Component {
        id: mapComponent

        MapComponent{

            property string textCCTitle: qsTr("Coordinates")
            property string textCCMessage: qsTr("<b>Latitude: %1</b><br/><b>Longitude: %2</b>")
            property string textECTitle: qsTr("ProviderError")
            property string textECMessage: qsTr("%1<br/><br/><b>Map provider error</b>")

            width: page.width
            height: page.height
            onFollowmeChanged: drawer.isFollowMe = map.followme
            onCoordinatesCaptured:
                stackView.showMessage(textCCTitle, textCCMessage.arg(roundNumber(latitude,6)).arg(roundNumber(longitude,6)));

            onErrorChanged: {
                if (map.error !== Map.NoError) {
                    stackView.showMessage(textECTitle, textECMessage.arg(map.errorString));
                }
            }
            onShowMainMenu: mapPopupMenu.show(coordinate)
            onShowTargetMenu: targetPopupMenu.show(coordinate)

            onBoxChanged: {
                webMan.setBox(longitudeMin, longitudeMax, latitudeMin, latitudeMax)
            }
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent

        initialItem: Item {
            id: page
        }

        function showMessage(title, message, imageUrl)
        {
            push(messageForm, { "title" : title, "message" : message, "imageUrl": imageUrl })
        }

        function closeMessage(backPage)
        {
            pop(backPage)
        }

        function closeForm()
        {
            pop(page)
        }
    }


}
