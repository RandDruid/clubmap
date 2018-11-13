import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

Item {
    property alias mainMenu: mainMenu
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

    property int iconId: -1

    signal menuTriggered(string item)
    signal changeWantSendPositionInt(int newValue)
    signal changeWantSendPositionBool(bool newValue)
    signal changeWantGetTargetsInt(int newValue)
    signal changeWantGetTargetsBool(bool newValue)
    signal changeFixedPosition(string latitude, string longitude)
    signal changePositionSource(bool online)
    signal changeIcon(int newValue)

    ScrollView {
        anchors.fill: parent

        RowLayout {
            id: mainMenu
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            ColumnLayout {
                RowLayout {
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

                Switch {
                    id: wantGetTargetsItem
                    padding: 0
                    text: qsTr("Download Club Data")
                    topPadding: 8
                    leftPadding: 8
                    checked: wantGetTargetsBool
                }

                RowLayout {
                    GroupBox {
                        padding: 8
                        ColumnLayout {
                            enabled: wantGetTargetsBool

                            Text {
                                id: textGetTargets
                                text: "TIME\nTIME\nTIME"
                                Layout.fillWidth: false
                                Layout.alignment: Qt.AlignHCenter
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Dial {
                                id: dialGetTargets
                                live: true
                                stepSize: 10
                                to: 1200
                                from: 10
                            }
                        }
                    }
                    GroupBox {
                        id: groupBox
                        Layout.fillWidth: true
                        padding: 8
                        Layout.fillHeight: true
                        ColumnLayout {
                            anchors.right: parent.right
                            anchors.rightMargin: 0
                            anchors.left: parent.left
                            anchors.leftMargin: 0
                            anchors.top: parent.top
                            anchors.topMargin: 0
                            clip: false
                            Text {
                                text: qsTr("Login")
                                Layout.alignment: Qt.AlignLeft
                            }
                            TextField {
                                id: textLogin
                                text: ""
                                placeholderText: "login"
                                Layout.fillWidth: true
                                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                            }
                            Text {
                                text: qsTr("Password")
                                Layout.alignment: Qt.AlignLeft
                            }
                            TextField {
                                id: textPassword
                                echoMode: TextInput.Password
                                passwordMaskDelay: 500
                                placeholderText: "password"
                                Layout.fillWidth: true
                            }
                            Button {
                                id: buttonCredentials
                                Layout.fillWidth: true
                                text: qsTr("Set")
                            }
                        }
                    }
                }

                GroupBox {
                    bottomPadding: 8
                    padding: 8
                    Layout.fillWidth: true
                    topPadding: 42
                    label: Switch {
                        id: wantSendPositionItem
                        text: qsTr("Send My Position")
                        topPadding: 8
                        leftPadding: 8
                        padding: 0
                        checked: wantSendPositionBool
                    }

                    RowLayout {
                        anchors.fill: parent
                        enabled: wantSendPositionBool

                        ColumnLayout {
                            Text {
                                id: textSendPosition
                                Layout.alignment: Qt.AlignHCenter
                                text: "TIME\nTIME\nTIME"
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Dial {
                                id: dialSendPosition
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
                            ColumnLayout {
                                anchors.right: parent.right
                                anchors.rightMargin: 0
                                anchors.left: parent.left
                                anchors.leftMargin: 0
                                anchors.top: parent.top
                                anchors.topMargin: 0
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
                                    Layout.fillWidth: true
                                    text: qsTr("Set")
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    ComboBox {
                        id: cbSelectLanguage
                        textRole: "text"
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Button {
                        id: btnAbout
                        text: qsTr("About")
                    }
                }
            }

            GroupBox {
                title: qsTr("Icon")
                Layout.fillHeight: true
                padding: 0
                width: 42
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
}


/*##^## Designer {
    D{i:0;autoSize:true;height:700;width:330}
}
 ##^##*/
