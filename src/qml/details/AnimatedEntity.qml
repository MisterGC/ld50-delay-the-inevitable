// (c) serein.pfeiffer@gmail.com - zlib license, see "LICENSE" file

import QtQuick
import Box2D
import Clayground.Physics
import Clayground.Svg

SpriteBoxBody
{
    id: theEntity

    bodyType: Body.Static
    property string sourceSvg: "visuals"
}
