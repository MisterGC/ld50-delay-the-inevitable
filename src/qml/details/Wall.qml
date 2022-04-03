// (c) serein.pfeiffer@gmail.com - zlib license, see "LICENSE" file

import QtQuick
import Box2D
import Clayground.Physics

RectBoxBody
{
    id: _wall
    bodyType: Body.Static
    color: "#2adcff"
    categories: collCat.staticGeo
    collidesWith: collCat.player | collCat.enemy

    SequentialAnimation{
        running: true
        loops: Animation.Infinite
        NumberAnimation {target: _wall; property: "opacity"; duration: 2000; from: .5; to: .7  }
        NumberAnimation {target: _wall; property: "opacity"; duration: 2000; from: .7; to: .5  }
    }
}
