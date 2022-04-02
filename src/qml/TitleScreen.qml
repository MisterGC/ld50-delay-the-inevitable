// (c) serein.pfeiffer@gmail.com - zlib license, see "LICENSE" file

import QtQuick
import QtQuick.Controls

import "details"

Item {
    Component.onCompleted: {
        if (gameMusic.sound != "menu_music")
            gameMusic.playLooped("menu_music")
    }

    Image {
        id: titleImg
        anchors.centerIn: parent
        source: assets.visual("visuals/title_image")
        fillMode: Image.PreserveAspectFit
        width: stack.width * .8
        height: (sourceSize.height / sourceSize.width) * width
        MouseArea {
            anchors.fill: parent
            onClicked: gameApp.transitionTo(menuScreenComp)
        }
    }
}
