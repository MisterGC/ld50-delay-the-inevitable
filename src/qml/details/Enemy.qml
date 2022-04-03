// (c) serein.pfeiffer@gmail.com - zlib license, see "LICENSE" file

import QtQuick
import QtMultimedia
import QtQuick.Particles
import Box2D
import Clayground.Physics
import Clayground.Svg
import Clayground.Behavior

LivingEntity
{
    id: enemy

    active: visible
    property alias attackable: _mouseArea.visible
    categories: collCat.enemy
    collidesWith: collCat.staticGeo | collCat.player | collCat.detector
    bodyType: Body.Dynamic; sensor: true;
    maxHealth: 1
    onHealthChanged:{
        if (health <= 0) {
            let toAbsorb = (health < -5);
            let comp = toAbsorb ? _absorbAnimComp : _deathAnimComp
            comp.createObject(enemy.parent, {
                                  x: enemy.x,
                                  y: enemy.y,
                                  width: enemy.width,
                                  height: enemy.height }
                              );

            if (!toAbsorb){
                _corpseComp.createObject(enemy.parent, {
                                             x: enemy.x,
                                             y: enemy.y,
                                             width: enemy.width,
                                             height: enemy.height }
                                         );
            }
            enemy.visible = false;
        }
    }

    property var spawnArea: spawnAreas[Math.round(Math.random() * (spawnAreas.length - 1))]
    function rndSpawnAreaX(obj){return obj.xWu + Math.random() * (obj.widthWu-widthWu)}
    function rndSpawnAreaY(obj){return obj.yWu - Math.random() * (obj.heightWu-heightWu)}
    xWu: rndSpawnAreaX(spawnArea); yWu: rndSpawnAreaY(spawnArea); widthWu: player.widthWu*.8; heightWu: widthWu;

    visu.sprites: [
        Sprite {
            name: "enemy";
            source: assets.visual(sourceSvg + "/" + name)
            frameCount: 1
            frameRate: 1
        }

    ]

    MoveTo {
        desiredSpeed: 15
        world: gameScene; anchors.centerIn: parent;
        function updateDest() {destXWu = rndSpawnAreaX(demonTag); destYWu = rndSpawnAreaY(demonTag)}
        Component.onCompleted: updateDest(); running: true;
        //onArrived: updateDest()
        //debug: true; debugColor: "red"
    }

    signal picked(var entity)
    MouseArea{
        id: _mouseArea
        visible: false
        anchors.centerIn: parent
        width: parent.width * 4
        height: parent.height * 4
        onClicked: {picked(enemy);}
        Rectangle{z: -10; color: "blue"; opacity: .2; anchors.fill: parent}

    }

    Component{
        id: _deathAnimComp
        ParticleSystem {
            id: _deathAnim
            running: true
            Component.onCompleted: {emitter.burst(50)}
            Timer{interval: emitter.lifeSpan; running: true; onTriggered: enemy.destroy()}
            Emitter {
                id: emitter
                anchors.centerIn: parent
                enabled: false
                lifeSpan: 200
                velocity: AngleDirection{
                    magnitude: 10 * _deathAnim.width;
                    magnitudeVariation: magnitude * .1
                    angleVariation: 360 }
            }

            ItemParticle {
                delegate: Rectangle { width: _deathAnim.width * .5; height: width
                    color: "green"; opacity: 0.5; rotation: Math.random() * 360 }
            }

        }
    }

    Component{
        id: _absorbAnimComp
        ParticleSystem {
            id: _absorbAnim
            Component.onCompleted: emitter.burst(100)
            Timer{interval: emitter.lifeSpan; running: true; onTriggered: enemy.destroy()}
            Emitter
            {
                id: emitter
                width: _absorbAnim.width
                height: width
                anchors.centerIn: parent
                emitRate: 100
                enabled: false
                lifeSpan: 500
                velocity: TargetDirection {
                    targetX: emitter.width * .5
                    targetY: emitter.height * .5
                    magnitude: 1000.0 / emitter.lifeSpan
                    proportionalMagnitude: true
                }
            }
            ItemParticle {
                delegate: Rectangle {
                    width: _absorbAnim.width * .2
                    height: width
                    color: "orange"
                }
            }
        }
    }

    Component{
        id: _corpseComp
        Item{
            Behavior on opacity{NumberAnimation{duration: 10000}}
            Component.onCompleted: opacity = 0;
            visible: opacity > .1
            onVisibleChanged: if (!visible) destroy();
            Repeater{
                model: 3
                Rectangle{color: "green"; opacity: Math.random() * 0.2 + 0.2
                    x: Math.random() * (parent.width - width)
                    y: Math.random() * (parent.height - height)
                    width: .3 * parent.width + Math.random() * .5 * parent.width
                    height: .3 * parent.height + Math.random() * .5 * parent.height
                }
            }
        }
    }

}
