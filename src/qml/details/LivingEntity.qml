// (c) serein.pfeiffer@gmail.com - zlib license, see "LICENSE" file

import QtQuick
import Box2D
import Clayground.Physics
import Clayground.Svg

AnimatedEntity
{
    id: theEntity

    bodyType: Body.Dynamic
    property int maxHealth: 3
    property int health: maxHealth
    property bool isAlive: health >= 1
    property bool invulnerable: false
}
