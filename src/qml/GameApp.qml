// (c) serein.pfeiffer@gmail.com - zlib license, see "LICENSE" file

import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtMultimedia

import "details"

Rectangle
{
    id: gameApp

    anchors.fill: parent
    color: "black"

    SharedState { id: gameState }
    Component.onCompleted: gameState.load()

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: gameSceneComp
    }

    Component {id: titleScreenComp; TitleScreen {}}
    Component {id: infoScreenComp; InfoScreen{}}
    Component {id: menuScreenComp; MenuScreen {}}
    Component {id: gameSceneComp; GameScene{}}
    Component {id: endingScreenComp; EndingScreen{}}
    AssetProvider { id: assets }

    MediaPlayer {
        id: gameMusic
        property string sound: ""
        source: assets.sound(sound)
        property alias volume: audioOut.volume
        audioOutput: AudioOutput {id: audioOut; muted: gameState.muteMusic }
        function _play(snd) {stop(); volume = 1; sound=snd; play();}
        function playLooped(snd) {loops = SoundEffect.Infinite; _play(snd);}
        function playOneTime(snd){loops = 1; _play(snd);}
    }

    property var transitionScreenTarget: null
    function transitionTo(screenComp, withTransitionScreen) {
        if (withTransitionScreen)
            transitionScreenTarget = screenComp;
        else
            stack.replace(screenComp);
    }
    onTransitionScreenTargetChanged: if (transitionScreenTarget) stack.replace(transitionScreen)
    Component {
        id: transitionScreen
        Rectangle {
            color: "black"
            Timer {
                interval: 500
                running: true
                onTriggered: gameApp.transitionTo(transitionScreenTarget)
            }
        }
    }

}
