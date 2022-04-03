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
                                  height: enemy.height
                                  }
                              );

            if (!toAbsorb){
                _corpseComp.createObject(enemy.parent, {
                                             x: enemy.x - enemy.width * .5,
                                             y: enemy.y - enemy.height * .5,
                                             width: enemy.width * 2,
                                             height: enemy.height * 2}
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
        desiredSpeed: 5 + Math.random() * 15
        world: gameScene; anchors.centerIn: parent;
        function updateDest() {destXWu = rndSpawnAreaX(demonTag); destYWu = rndSpawnAreaY(demonTag)}
        Component.onCompleted: updateDest(); running: true;
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
                endSize: 2
                velocity: AngleDirection{
                    magnitude: 10 * _deathAnim.width;
                    magnitudeVariation: magnitude * .1
                    angleVariation: 360 }
            }

            ItemParticle {
                delegate: Rectangle { width: _deathAnim.width * .5; height: width
                    color: "#2fcf00"; opacity: 0.5; rotation: Math.random() * 360 }
            }

        }
    }

    Component{
        id: _absorbAnimComp
        ParticleSystem {
            id: _absorbAnim
            Component.onCompleted: emitter.burst(100)
            Timer{interval: emitter.lifeSpan; running: true; onTriggered: {enemy.destroy(); _absorbAnim.destroy()}}
            Emitter
            {
                id: emitter
                width: _absorbAnim.width * 3
                height: width
                anchors.centerIn: parent
                emitRate: 100
                lifeSpan: 500
                enabled: false
                velocity: TargetDirection {
                    targetX: emitter.width * .5
                    targetY: emitter.height * .5
                    magnitude: 1000.0 / emitter.lifeSpan
                    proportionalMagnitude: true
                }
            }
            ItemParticle {
                delegate: Rectangle {
                    width: _absorbAnim.width * .1
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
                Rectangle{color: "#2fcf00"; opacity: Math.random() * 0.2 + 0.2
                    x: Math.random() * (parent.width - width)
                    y: Math.random() * (parent.height - height)
                    width: .3 * parent.width + Math.random() * .5 * parent.width
                    height: .3 * parent.height + Math.random() * .5 * parent.height
                }
            }
        }
    }

}
