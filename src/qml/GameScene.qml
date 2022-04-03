// (c) serein.pfeiffer@gmail.com - zlib license, see "LICENSE" file

import QtQuick
import QtQuick.Controls
import QtMultimedia
import QtQuick.Particles
import Box2D
import Clayground.GameController
import Clayground.World
import Clayground.Behavior
import Clayground.Physics

import "details"

ClayWorld {
    id: gameScene

    // RENDER SETTINGS
    pixelPerUnit: width / (.8 * gameScene.worldXMax)

    // SCENE CREATION CFG: Map Entity Types -> Components to be intialized
    components: new Map([
                    ['Player', c1],
                    ['Enemy', c2],
                    ['Wall', c3],
                    ['Floor', c4],
                    ['Finish', c5],
                    ['StaticEntity', c6],
                    ['MagmaDemonTag', c7],
                    ['SpawnArea', spawnAreaComp]
                ])
    Component { id: c1; Player {} }
    Component { id: c2; Enemy {} }
    Component { id: c3; Wall {} }
    Component { id: c4; Floor {} }
    Component { id: c5; RectTrigger {
            categories: collCat.staticGeo; collidesWith: collCat.player
            onEntered: {gameApp.transitionTo(endingScreenComp, true); }
        } }
    Component { id: c6; StaticEntity {} }
    Component { id: c7; MagmaDemonTag {} }


    // PHYSICS SETTINGS
    gravity: Qt.point(0,0)
    timeStep: 1/60.0
    //physicsDebugging: true
    QtObject {
        id: collCat
        readonly property int staticGeo: Box.Category1
        readonly property int player: Box.Category2
        readonly property int enemy: Box.Category3
        readonly property int detector: Box.Category4
        readonly property int noCollision: Box.None
    }

    running: !player ? false : (player.isAlive &&
             (!demonTag ? false : demonTag.opacity < .99))
    property var player: null

    onMapAboutToBeLoaded: {player = null;}
    onMapLoaded: {
        theGameCtrl.selectKeyboard(Qt.Key_S,
                                   Qt.Key_W,
                                   Qt.Key_A,
                                   Qt.Key_D,
                                   Qt.Key_J,
                                   Qt.Key_K);
        gameScene.observedItem = player;
        gameState.fontPixelSize = player.height * .4
        gameMusic.playLooped("level_music");
        _spawner.start();
    }

    interactive: false
    Keys.forwardTo: theGameCtrl
    GameController {
        id: theGameCtrl;
        anchors.fill: parent
        signal attack(var point)
        signal rushTo(var point)
        MouseArea {
           anchors.fill: parent
           acceptedButtons: Qt.LeftButton | Qt.RightButton
           onClicked: (mouse) =>
                      {
                         let p = gameScene.room.mapFromItem(theGameCtrl, mouse.x, mouse.y);
                         if(mouse.button === Qt.LeftButton) {
                             theGameCtrl.attack(p)
                          }
                         if(mouse.button === Qt.RightButton)
                             theGameCtrl.rushTo(p)
                      }
        }

    }

    HealthBar {
        id: healthBar
        observed: player
        anchors.top: parent.top
        anchors.topMargin: gameState.safeTopMargin
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text{
        id: _stopWatch
        property real _passedSec: 0.0
        Timer{id: _stopWatchTim; interval: 100;
            running: gameScene.running;
            onRunningChanged: if (running) _stopWatch._passedSec = 0.0
            repeat: true; onTriggered: parent._passedSec = Math.round((parent._passedSec+.1)*10)/10; }
        text: _passedSec; color: "white"
        font.family: "Monospace"; font.pixelSize: _intro.font.pixelSize;
    }

    component GameText: Text{
        font.family: "Monospace";font.pixelSize: _intro.font.pixelSize; color: "white"
    }

    MouseArea{
        enabled: _intro.telling
        visible: enabled
        anchors.fill: parent
        StoryText{
            id: _intro
            story: [
                {duration: 2000, pause: 500, text: "You are the guard of a demon gate ..."},
                {duration: 2000, pause: 500, text: "Creature are coming to summon their master ..."},
                {duration: 2000, pause: 500, text: "Stop them as long as possible ..."},
                {duration: 2000, pause: 500, text: "Get ready ..."},
                {duration: 750, pause: 400, fade: 200,  text: "3"},
                {duration: 750, pause: 400, fade: 200,  text: "2"},
                {duration: 750, pause: 400, fade: 200,  text: "1"},
                {duration: 750, pause: 400, fade: 200,  text: "GO"},
            ]
            color: "white";
            font.pixelSize: gameScene.height * .04;  anchors.centerIn: parent
            onTellingChanged: if(!telling) map = assets.scene(gameState.level)
        }
        onClicked: _intro.visible = false
        GameText{anchors.bottom: parent.bottom; anchors.bottomMargin: 8* height;
                 font.pixelSize: _intro.font.pixelSize * .75
                 anchors.horizontalCenter: parent.horizontalCenter; text: "Click to skip the intro ..."}
    }

    MouseArea{
        id: _outro
        visible: false
        enabled: opacity > .99
        opacity: 0
        Behavior on opacity {NumberAnimation{duration: 1000}}
        onVisibleChanged: if(visible) opacity=1.0
        Timer{interval: 1500; running: parent.visible; onTriggered: parent.enabled = true;}
        Connections{target: gameScene; function onRunningChanged(){_outro.visible = !gameScene.running;}}
        anchors.fill: parent
        Rectangle{z: -1; anchors.fill: parent; color: "black"; opacity: .75}
        Column{
            anchors.centerIn: parent
            GameText{
                 text: "Failure is not the opposite of " +
                       "success\nit's part of success.\n\n"
            }
            GameText{text: "Protection time: "}
            GameText{font.pixelSize: 2*_intro.font.pixelSize; text: _stopWatch._passedSec + " seconds"}
            GameText{text: "\nTry again by clicking ...  "}
        }
        onClicked: {gameApp.transitionTo(gameSceneComp, true); }
    }


    property var spawnAreas: []
    Component{
        id: spawnAreaComp;
        RectBoxBody{
            visible: true; z:-2; color: "black"; active: false
            ParticleSystem {
                anchors.centerIn: parent
                Emitter {
                    id: _emitter
                    enabled: true
                    anchors.centerIn: parent
                    lifeSpan: 3000
                    endSize: 1
                    emitRate: 20
                    velocity: AngleDirection{
                        magnitude: player.height * 2; angle: -90
                        angleVariation: 30; }
                }

                ItemParticle {
                    delegate: Rectangle {
                        width: player.width *.2 * Math.random()
                        height: width
                        color: "#5aff2a"
                        //rotation: Math.random() * 20
                    }
                }
                Gravity{angle: 90; magnitude: player.height}
            }
        }

    }
    Timer{id: _spawner; repeat: true; interval: 500 ;
        property int numEnemies: 0; property int maxEnemies: 1 + Math.round(_stopWatch._passedSec/10) ;
        onTriggered: {
            if (numEnemies < maxEnemies){
                let e = _enemyComp.createObject(gameScene.room);
                e.Component.destruction.connect(_ => {_spawner.onEnemyDied();});
                numEnemies++;
            }
        }

        function onEnemyDied(){numEnemies--;}
    }

    Component{id: _enemyComp; Enemy {}}

    property MagmaDemonTag demonTag: null
    onMapEntityCreated: (obj, groupId, compName) => {
        if (obj instanceof Player) {
            gameScene.player = obj;
            obj.z = 500;

        }
        else if(compName==="SpawnArea") spawnAreas.push(obj);
        else if(compName==="MagmaDemonTag") {demonTag = obj;}
    }

}
