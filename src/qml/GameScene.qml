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

    Component.onCompleted: map = assets.scene(gameState.level)

    // RENDER SETTINGS
    pixelPerUnit: width / gameScene.worldXMax

    // SCENE CREATION CFG: Map Entity Types -> Components to be intialized
    components: new Map([
                    ['Player', c1],
                    ['Enemy', c2],
                    ['Wall', c3],
                    ['Floor', c4],
                    ['Finish', c5],
                    ['StaticEntity', c6],
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
        console.log("size: " + spawnAreas.length)
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
    Component{id: spawnAreaComp; RectBoxBody{visible: false; z:-1; color: "#92dfbd"; active: false} }
    Timer{id: _spawner; repeat: true; interval: 2000; onTriggered: _enemyComp.createObject(gameScene.room);}

    Component{
        id: _enemyComp
        Enemy {
            property var spawnArea: spawnAreas[Math.round(Math.random() * (spawnAreas.length - 1))]
            function rndSpawnArea(){return spawnAreas[Math.round(Math.random() * (spawnAreas.length - 1))];}
            function rndSpawnAreaX(){return spawnArea.xWu + Math.random() * (spawnArea.widthWu-widthWu)}
            function rndSpawnAreaY(){return spawnArea.yWu - Math.random() * (spawnArea.heightWu-heightWu)}
            xWu: rndSpawnAreaX(); yWu: rndSpawnAreaY(); widthWu: player.widthWu*.8; heightWu: widthWu;
            bodyType: Body.Kinematic; sensor: true;
            MoveTo {
                desiredSpeed: 15
                world: gameScene; anchors.centerIn: parent;
                function updateDest() {spawnArea= rndSpawnArea(); destXWu = rndSpawnAreaX(); destYWu = rndSpawnAreaY()}
                Component.onCompleted: updateDest(); running: true; onArrived: updateDest()
                debug: true; debugColor: "red"

            }
        }
    }

    onMapEntityCreated: (obj, groupId, compName) => {
        if (obj instanceof Player) {
            gameScene.player = obj;
            obj.z = 500;
        }
        else if(compName==="SpawnArea") spawnAreas.push(obj);
    }

}
