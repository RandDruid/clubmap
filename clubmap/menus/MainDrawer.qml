import QtQuick 2.11
import QtQuick.Controls 2.4

MainDrawerForm {

    tumblerIcon.model: [
        {"imageSource": "qrc:/images/ticon0.png", "iconId": 0},
        {"imageSource": "qrc:/images/ticon1.png", "iconId": 1},
        {"imageSource": "qrc:/images/ticon2.png", "iconId": 2},
        {"imageSource": "qrc:/images/ticon3.png", "iconId": 3},
        {"imageSource": "qrc:/images/ticon4.png", "iconId": 4},
        {"imageSource": "qrc:/images/ticon5.png", "iconId": 5},
        {"imageSource": "qrc:/images/ticon6.png", "iconId": 6},
        {"imageSource": "qrc:/images/ticon7.png", "iconId": 7},
        {"imageSource": "qrc:/images/ticon8.png", "iconId": 8},
        {"imageSource": "qrc:/images/ticon9.png", "iconId": 9}
    ]

    property string strGetTargets: qsTr("Refresh\nevery:\n")
    property string strSendPosition: qsTr("Minimum\ninterval:\n")

    Component.onCompleted: {
        switch (Qt.locale().name.substring(0,2)) {
            case "en":
                cbSelectLanguage.currentIndex = 0;
                break;
            case "ru":
                cbSelectLanguage.currentIndex = 1;
                break;
            default:
                cbSelectLanguage.currentIndex = 0;
        }
    }

    function findIconItemById(itemId) {
        for (var i = 0; i < tumblerIcon.model.length; i++) {
            if (tumblerIcon.model[i].iconId === itemId) return i;
        }
        return 0;
    }

    function adjustIcon() {
        tumblerIcon.currentIndex = findIconItemById(iconId);
    }

    onIconIdChanged: {
        adjustIcon();
    }

    tumblerIcon.onCurrentIndexChanged: {
        changeIcon(tumblerIcon.model[tumblerIcon.currentIndex].iconId);
    }

    buttonBack.onPressed: menuTriggered("back")

    btnAbout.onPressed: menuTriggered("about")

    minimapItem.onCheckedChanged: menuTriggered("minimap")

    followmeItem.onCheckedChanged: menuTriggered("followme")

    // ------------------------------------------------------------------------------------- want send position

    onWantSendPositionIntChanged: {
        textSendPosition.text = formatTime(dialSendPosition.value, strSendPosition);
    }
    wantSendPositionItem.onCheckedChanged: {
        if (wantSendPositionBool !== wantSendPositionItem.checked)
            changeWantSendPositionBool(wantSendPositionItem.checked);
    }

    dialSendPosition.onMoved: {
        changeWantSendPositionInt(dialSendPosition.value);
        textSendPosition.text = formatTime(dialSendPosition.value, strSendPosition);
    }

    // ------------------------------------------------------------------------------------- want get targets

    onWantGetTargetsIntChanged: {
        textGetTargets.text = formatTime(dialGetTargets.value, strGetTargets);
    }

    wantGetTargetsItem.onCheckedChanged: {
        if (wantGetTargetsBool !== wantGetTargetsItem.checked)
            changeWantGetTargetsBool(wantGetTargetsItem.checked);
    }

    dialGetTargets.onMoved: {
        changeWantGetTargetsInt(dialGetTargets.value);
        textGetTargets.text = formatTime(dialGetTargets.value, strGetTargets);
    }

    // ---------------------------------------------------------------------------------------

    buttonFixedPosition.onPressed: {
        changeFixedPosition(textPositionLatitude.text, textPositionLongitude.text)
    }

    buttonCredentials.onPressed: {
        webMan.setUser(textLogin.text, textPassword.text);
    }

    switchPositionSourceDefault.onCheckedChanged: {
        changePositionSource(switchPositionSourceDefault.checked)
    }

    cbSelectLanguage.onCurrentIndexChanged: {
        if (cbSelectLanguage.currentIndex > -1) {
            webMan.setLanguage(modelLanguages.get(cbSelectLanguage.currentIndex).value);
        }
    }

    // required for dynamic translations update
    onStrGetTargetsChanged: {
        textGetTargets.text = formatTime(dialGetTargets.value, strGetTargets);
    }

    onStrSendPositionChanged: {
        textSendPosition.text = formatTime(dialSendPosition.value, strSendPosition);
    }

    function load() {
        textLogin.text = settings.valueNVEC("forum/login", "");
        webMan.loadSettings();
    }

    function save() {
    }

    function formatTime(value, s) {
        if (value < 1) {
            return s + qsTr("never")
        } else if (value < 60) {
            return s + value.toFixed(0) + qsTr(" sec")
        } else {
            return s + (value / 60).toFixed(0) + qsTr(" min ") + (value % 60).toFixed(0) + qsTr(" sec")
        }
    }
}

/*##^## Designer {
    D{i:0;autoSize:true;height:960;width:640}
}
 ##^##*/