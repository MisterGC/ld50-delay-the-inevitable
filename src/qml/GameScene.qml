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

    MouseArea{
        enabled: _intro.telling
        anchors.fill: parent
        GameText{
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
    }

    // RENDER SETTINGS
    pixelPerUnit: width / (.7 * gameScene.worldXMax)

    Text{anchors.top: parent.top}

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
            onEntered: {console.log("Game Finished"); gameApp.transitionTo(endingScreenComp, true); }
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

    running: !player ? false : player.isAlive && !paused
    property bool paused: false
    onPausedChanged: gameMusic.volume = gameScene.paused ? .5 : 1
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
    GameController { id: theGameCtrl; anchors.fill: parent }

    HealthBar {
        id: healthBar
        observed: player
        anchors.top: parent.top
        anchors.topMargin: gameState.safeTopMargin
        anchors.horizontalCenter: parent.horizontalCenter
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
                        magnitude: 100; angle: -90
                        angleVariation: 30; }
                }

                ItemParticle {
                    delegate: Rectangle {
                        width: 10 + Math.random() * 10
                        height: width
                        color: "#5aff2a"
                        rotation: Math.random() * 20
                    }
                }
                Gravity{angle: 90; magnitude: 60}
            }
        }

    }
    Timer{id: _spawner; repeat: true; interval: 1000;
        property int numEnemies: 0; property int maxEnemies: 10;
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
                            console.log(compName)
        if (obj instanceof Player) {
            gameScene.player = obj;
            obj.z = 500;

        }
        else if(compName==="SpawnArea") spawnAreas.push(obj);
        else if(compName==="MagmaDemonTag") {console.log("Found demon tag");demonTag = obj;}
    }

}
