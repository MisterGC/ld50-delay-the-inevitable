// (c) serein.pfeiffer@gmail.com - zlib license, see "LICENSE" file

import QtQuick
import Box2D
import Clayground.Physics

RectBoxBody
{
    bodyType: Body.Static
    color: "#504a49"
    categories: collCat.staticGeo
    collidesWith: collCat.player | collCat.enemy
}
