// (c) serein.pfeiffer@gmail.com - zlib license, see "LICENSE" file

import QtQuick
import QtMultimedia
import QtQuick.Particles
import Box2D
import Clayground.Physics
import Clayground.Svg

LivingEntity
{
    id: enemy

    active: visible
    property alias attackable: _mouseArea.visible
    categories: collCat.enemy
    collidesWith: collCat.staticGeo | collCat.player | collCat.detector
    bodyType: Body.Dynamic
    maxHealth: 1
    onHealthChanged:{
        if (health <= 0) {
            _deathAnimComp.createObject(enemy.parent, {
                                        x: enemy.x,
                                        y: enemy.y,
                                        width: enemy.width,
                                        height: enemy.height }
                                    );
            enemy.visible = false;
        }
    }

    visu.sprites: [
        Sprite {
            name: "enemy";
            source: assets.visual(sourceSvg + "/" + name)
            frameCount: 1
            frameRate: 1
        }
    ]

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
            Timer{interval: emitter.lifeSpan; running: true; onTriggered: enemy.destroy}
            Emitter {
                id: emitter
                anchors.centerIn: parent
                enabled: false
                lifeSpan: 4000
                velocity: AngleDirection{
                    magnitude: 5 * _deathAnim.width;
                    magnitudeVariation: magnitude * .1
                    angleVariation: 360 }
            }
            ItemParticle {
                delegate: Rectangle { width: _deathAnim.width * .5; height: width
                    color: "black"; rotation: Math.random() * 360 }
            }

        }
    }

}
