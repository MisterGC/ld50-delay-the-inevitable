// (c) serein.pfeiffer@gmail.com - zlib license, see "LICENSE" file

import QtQuick
import Box2D
import Clayground.Physics
import Clayground.Svg

StaticEntity
{
    id: _tile
    active: false // no need for physics
    fillMode: Image.Tile
    tileWidthWu: 5
    tileHeightWu: 5

    SequentialAnimation{
        running: true
        loops: Animation.Infinite
        NumberAnimation {target: _tile; property: "opacity"; duration: 2000; from: .3; to: .1  }
        NumberAnimation {target: _tile; property: "opacity"; duration: 2000; from: .1; to: .3  }
    }
}
