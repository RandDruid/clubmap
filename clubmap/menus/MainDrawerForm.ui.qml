import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

Item {
    id: item1
    property alias minimapItem: minimapItem
    property alias followmeItem: followmeItem
    property alias cbSelectLanguage: cbSelectLanguage
    property alias wantSendPositionItem: wantSendPositionItem
    property alias textSendPosition: textSendPosition
    property alias textGetTargets: textGetTargets
    property alias dialSendPosition: dialSendPosition
    property alias dialGetTargets: dialGetTargets
    property alias buttonFixedPosition: buttonFixedPosition
    property alias textPositionLatitude: textPositionLatitude
    property alias textPositionLongitude: textPositionLongitude
    property alias switchPositionSourceDefault: switchPositionSourceDefault
    property alias wantGetTargetsItem: wantGetTargetsItem
    property alias tumblerIcon: tumblerIcon
    property alias buttonBack: buttonBack
    property alias btnAbout: btnAbout
    property alias cbSelectMapType: cbSelectMapType

    property alias buttonCredentials: buttonCredentials
    property alias textLogin: textLogin
    property alias textPassword: textPassword

    property bool isFollowMe
    property bool isMiniMap

    property int wantSendPositionInt
    property bool wantSendPositionBool
    property int wantGetTargetsInt
    property bool wantGetTargetsBool

    property bool isPositionLive
    property string fixedPositionLatitude
    property string fixedPositionLongitude
    property string selectedLanguage
    property string selectedMapType

    property int iconId: -1

    signal menuTriggered(string item)
    signal changeWantSendPositionInt(int newValue)
    signal changeWantSendPositionBool(bool newValue)
    signal changeWantGetTargetsInt(int newValue)
    signal changeWantGetTargetsBool(bool newValue)
    signal changeFixedPosition(string latitude, string longitude)
    signal changePositionSource(bool online)
    signal changeIcon(int newValue)
    signal recreateMap(string mapType)

    ScrollView {
        id: scrollRoot
        clip: true
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.top: parent.top

        ColumnLayout {
            anchors.rightMargin: 50
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right

            RowLayout {
                Layout.fillWidth: true
                Image {
                    Layout.alignment: Qt.AlignTop
                    Layout.maximumWidth: 48
                    Layout.maximumHeight: 48
                    source: "qrc:/images/left-arrow.png"

                    MouseArea {
                        id: buttonBack
                        anchors.fill: parent
                    }
                }

                ColumnLayout {
                    Switch {
                        id: minimapItem
                        text: qsTr("Minimap")
                        leftPadding: 32
                        bottomPadding: 0
                        checked: isMiniMap
                    }

                    Switch {
                        id: followmeItem
                        text: qsTr("Follow me")
                        leftPadding: 32
                        bottomPadding: 0
                        checked: isFollowMe
                    }
                }
            }

            ExpanderCheckBox {
                id: cbForumLoginSettings
                display: AbstractButton.TextBesideIcon
                text: qsTr("Forum Login")
            }

            GroupBox {
                id: groupBox
                padding: 8
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: cbForumLoginSettings.checked

                GridLayout {
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    columns: 2
                    rows: 3

                    Text {
                        Layout.alignment: Qt.AlignLeft
                        text: qsTr("Login")
                    }
                    Text {
                        text: qsTr("Password")
                        Layout.alignment: Qt.AlignLeft
                    }
                    TextField {
                        id: textLogin
                        text: ""
                        placeholderText: "login"
                        Layout.fillWidth: true
                        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                    }
                    TextField {
                        id: textPassword
                        echoMode: TextInput.Password
                        passwordMaskDelay: 500
                        placeholderText: "password"
                        Layout.fillWidth: true
                    }
                    Button {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        id: buttonCredentials
                        text: qsTr("Set")
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                ExpanderCheckBox {
                    id: cbGetTargetsSettings
                }

                Switch {
                    id: wantGetTargetsItem
                    text: "Download Club Data"
                    bottomPadding: 4
                    padding: 0
                    Layout.maximumWidth: 263
                    Layout.minimumWidth: 0
                    Layout.preferredWidth: -1
                    Layout.fillWidth: true
                    clip: true
                    topPadding: 4
                    leftPadding: 0
                    checked: wantGetTargetsBool
                }
            }

            GroupBox {
                visible: cbGetTargetsSettings.checked
                padding: 8
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    enabled: wantGetTargetsBool
                    anchors.fill: parent

                    Text {
                        id: textGetTargets
                        text: "TIME TIME TIME"
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Slider {
                        id: dialGetTargets
                        Layout.fillWidth: true
                        live: true
                        stepSize: 10
                        to: 1200
                        from: 10
                    }
                }
            }

            RowLayout {
                clip: true
                Layout.fillWidth: true

                ExpanderCheckBox {
                    id: cbWantSendPositionSettings
                    display: AbstractButton.IconOnly
                }

                Switch {
                    id: wantSendPositionItem
                    text: qsTr("Send My Position")
                    bottomPadding: 4
                    Layout.maximumWidth: 263
                    clip: true
                    Layout.fillWidth: true
                    topPadding: 4
                    leftPadding: 0
                    padding: 0
                    checked: wantSendPositionBool
                }
            }

            GroupBox {
                visible: cbWantSendPositionSettings.checked
                padding: 8
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent
                    enabled: wantSendPositionBool

                    ColumnLayout {
                        Text {
                            id: textSendPosition
                            Layout.alignment: Qt.AlignHCenter
                            text: "TIME TIME TIME"
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Slider {
                            id: dialSendPosition
                            Layout.fillWidth: true
                            live: true
                            stepSize: 10
                            to: 1200
                            from: 10
                        }
                    }

                    GroupBox {
                        id: groupBox1
                        Layout.fillWidth: true
                        leftPadding: 12
                        padding: 8
                        label: Switch {
                            id: switchPositionSourceDefault
                            text: qsTr("Auto")
                            leftPadding: 8
                            padding: 0
                            bottomPadding: 0
                            rightPadding: 0
                            checked: isPositionLive
                        }

                        GridLayout {
                            anchors.right: parent.right
                            anchors.left: parent.left
                            anchors.top: parent.top
                            columns: 2
                            rows: 3

                            Text {
                                Layout.alignment: Qt.AlignLeft
                                text: qsTr("Latitude")
                            }
                            Text {
                                text: qsTr("Longitude")
                                Layout.alignment: Qt.AlignLeft
                            }
                            TextField {
                                id: textPositionLatitude
                                width: 80
                                placeholderText: qsTr("Latitude")
                                text: fixedPositionLatitude
                                Layout.fillWidth: true
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                            }
                            TextField {
                                id: textPositionLongitude
                                width: 80
                                placeholderText: qsTr("Longitude")
                                text: fixedPositionLongitude
                                Layout.fillWidth: true
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                            }
                            Button {
                                id: buttonFixedPosition
                                Layout.columnSpan: 2
                                Layout.fillWidth: true
                                text: qsTr("Set")
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: qsTr("Map Type")
                    Layout.minimumWidth: 90
                    font.pointSize: 11
                }

                ComboBox {
                    id: cbSelectMapType
                    Layout.fillWidth: true
                    textRole: "text"
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: qsTr("Language")
                    Layout.minimumWidth: 90
                    font.pointSize: 11
                }

                ComboBox {
                    id: cbSelectLanguage
                    Layout.fillWidth: true
                    textRole: "text"
                }
            }

            Button {
                id: btnAbout
                text: qsTr("About")
                topPadding: 8
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }
        }

        GroupBox {
            id: gbIcon
            width: 48
            height: scrollRoot.height
            anchors.top: parent.top
            anchors.right: parent.right

            // height: scrollRoot.height
            title: qsTr("Icon")
            padding: 0
            font.bold: false

            Tumbler {
                id: tumblerIcon
                width: 40
                visibleItemCount: 7
                anchors.fill: parent
                wheelEnabled: true
                // 36 + 4
                enabled: true

                delegate: ItemDelegate {
                    property int iconIdint: modelData.iconId
                    anchors.margins: 0

                    Rectangle {
                        anchors.fill: parent
                        color: "lightblue"
                        visible: modelData.iconId === iconId
                    }

                    Image {
                        id: icon
                        width: 38
                        height: 38
                        anchors.centerIn: parent
                        source: modelData.imageSource
                        opacity: modelData.iconId === iconId ? 1.0 : 0.6
                    }
                }
            }
        }
    }
}


/*##^## Designer {
    D{i:0;autoSize:true;height:960;width:360}
}
 ##^##*/
