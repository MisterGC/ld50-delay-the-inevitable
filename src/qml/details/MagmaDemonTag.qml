// (c) serein.pfeiffer@gmail.com - zlib license, see "LICENSE" file

import QtQuick
import Box2D
import Clayground.Physics
import Clayground.Svg

ImageBoxBody
{
    property string sourcePath: ""
    source: assets.visual(sourcePath)
    bodyType: Body.Dynamic
    sensor: true
    property int numberOfEnts: 0
    opacity: .1 + numberOfEnts/90
    categories: collCat.detector
    collidesWith: collCat.enemy

    CollisionTracker{
       fixture: parent.fixture
       onBeginContact: (entity) => {entity.health=-10; parent.numberOfEnts++}

    }
}
