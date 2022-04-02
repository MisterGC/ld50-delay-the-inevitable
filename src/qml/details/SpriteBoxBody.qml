// (c) serein.pfeiffer@gmail.com - zlib license, see "LICENSE" file

import QtQuick
import Box2D
import Clayground.Physics

PhysicsItem {
    id: theItem

    property alias fixture: box

    // Sprite Properties
    property alias visu: theVisu
    property int spriteWidthWu: widthWu
    property int spriteHeightWu: heightWu

    // Box properties
    property alias density: box.density
    property alias friction: box.friction
    property alias restitution: box.restitution
    property alias sensor: box.sensor
    property alias categories: box.categories
    property alias collidesWith: box.collidesWith
    property alias groupIndex: box.groupIndex

    SpriteSequence {
        id: theVisu
        anchors.centerIn: parent
        interpolate: false
        width: theItem.spriteWidthWu * pixelPerUnit
        height: theItem.spriteHeightWu * pixelPerUnit
    }

    fixtures: [
        Box {
            id: box
            width: theItem.width
            height: theItem.height
        }
    ]
}
