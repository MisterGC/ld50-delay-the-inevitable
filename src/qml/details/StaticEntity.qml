// (c) serein.pfeiffer@gmail.com - zlib license, see "LICENSE" file

import QtQuick
import Box2D
import Clayground.Physics
import Clayground.Svg

ImageBoxBody
{
    property string sourcePath: ""
    source: assets.visual(sourcePath)
    bodyType: Body.Static
    active: false
}
