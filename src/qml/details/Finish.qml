// (c) serein.pfeiffer@gmail.com - zlib license, see "LICENSE" file

import QtQuick
import Box2D
import Clayground.Physics
import Clayground.Behavior

RectTrigger
{
    categories: collCat.staticGeo; collidesWith: collCat.player
}
