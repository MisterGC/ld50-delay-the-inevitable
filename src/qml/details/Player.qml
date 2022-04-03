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

    GameSound{
       id: ouch
       sound: "ouch.wav"
    }
    onHealthChanged: if (health < maxHealth) ouch.play();

    maxHealth: 5
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

    property real _veloCompMax: 25
    property real xDirDesire: theGameCtrl.axisX
    linearVelocity.x: xDirDesire * _veloCompMax
    property real yDirDesire: theGameCtrl.axisY
    linearVelocity.y: yDirDesire * _veloCompMax

    Connections{
        target: theGameCtrl
        function onAttack(point){
            let ents = perception.entities;
            let minDist = 10000;
            let hit = null;
            for (let e of ents){
                if (e instanceof Enemy && e.health > 0) {
                   let d = Qt.vector2d(player.x - e.x,
                                       player.y - e.y).length();
                    if(d < minDist){
                        minDist = d;
                        hit = e;
                    }
                }
            }
            if (hit) { sword.attack(hit) }
        }
        function onRushTo(point){
            let p = Qt.vector2d(point.x - x,point.y - y);
            p = p.normalized().times(width * 1.5);
            body.applyLinearImpulse(Qt.point(p.x, p.y), Qt.point(x, y));
            _veloCompMax = 50;
            _impulseStopper.start();
        }
    }

    Timer {
        id: _impulseStopper
        property var counterImpulse: null
        interval: 500
        onTriggered: {
            _veloCompMax = 25;
        }
    }

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

        debug: true
        width: 7 * player.width
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
