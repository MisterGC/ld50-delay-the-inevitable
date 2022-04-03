// (c) serein.pfeiffer@gmail.com - zlib license, see "LICENSE" file

import QtQuick
import QtMultimedia
import Box2D
import Clayground.Physics
import Clayground.Svg
import QtQuick.Particles

LivingEntity
{
    id: player

    property var enemy: null
    Component.onCompleted: {
        body.addFixture(areaOfDamage.createObject(player,{}));
        PhysicsUtils.connectOnEntered(fixtures[0], _onCollision)
    }
    function _onCollision(entity) { if (entity instanceof Enemy) health--;}

    maxHealth: 8
    spriteWidthWu: spriteHeightWu

    categories: collCat.player
    collidesWith: collCat.staticGeo | collCat.enemy

    visu.sprites: [
        Sprite {
            name: "player";
            source: assets.visual(sourceSvg + "/" + name)
            frameCount: 1
            frameRate: 1
        }
    ]

    readonly property real veloCompMax: 25
    property real xDirDesire: theGameCtrl.axisX
    linearVelocity.x: xDirDesire * veloCompMax
    property real yDirDesire: theGameCtrl.axisY
    linearVelocity.y: yDirDesire * veloCompMax

    Component {
        id: areaOfDamage
        Box {
            x: -player.width
            y: -player.height
            width: player.width * 3
            height: player.height * 3
            sensor: true
            categories: collCat.player
            collidesWith: collCat.enemy
        }
    }


    CollisionTracker {
        id: perception

        //debug: true
        width: 3 * player.width
        height: width
        anchors.centerIn: parent
        Component.onCompleted: {
            fixture = perceptAreaComp.createObject(player,{});
            player.body.addFixture(fixture);
        }
        Component {
            id: perceptAreaComp
            Box {
                sensor: true
                x: perception.x; y: perception.y
                width:  perception.width; height: perception.height
                categories: collCat.detector; collidesWith: collCat.enemy
            }
        }
        onBeginContact: (entity) => {
                            if (entity instanceof Enemy) {
                                entity.attackable = true;
                                entity.picked.connect(sword.attack)
                            }
                        }
        onEndContact: (entity) => {
                          if (entity instanceof Enemy){
                              entity.attackable = false;
                              entity.picked.disconnect(sword.attack);
                          }
                      }
    }


    Sword
    {
        id: sword
        width: player.width * .4
        height: player.height
        visible: swingAnim.running


        Timer {id: _coolDown; interval: 500;}
        function attack(target) {
            if (_coolDown.running) return;
            let p = player.mapFromItem(target, 0, 0)
            _hMovement.from = p.x -.25 *  target.width;
            _hMovement.to = p.x + 1.25 *  target.width;
            y = p.y;
            target.health--;
            swingAnim.start();
            _coolDown.start();
        }

        ParallelAnimation {
            id: swingAnim
            property int duration: 200
            NumberAnimation {
                target: sword
                property: "rotation"
                duration: swingAnim.duration
                from: -50; to: 50
            }
            NumberAnimation {
                id: _hMovement
                target: sword
                property: "x"
                duration: swingAnim.duration
                easing.type: Easing.InOutQuad
                from: -.25 * player.width
                to: 1.25 * player.width
            }
        }


    }

}
