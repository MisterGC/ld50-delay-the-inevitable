import QtQuick
import QtQuick.Controls
import Clayground.Svg

import "details"

Rectangle {
    id: menuButtons
    color: gameState.screenBgColor
    Text {
       anchors.centerIn: parent
       text: assets.text(assets.cCHOOSE_YOUR_SETTINGS)
    }
    MouseArea{
        anchors.fill: parent;
        onClicked: gameApp.transitionTo(gameSceneComp, true)
    }
}
