// (c) serein.pfeiffer@gmail.com - zlib license, see "LICENSE" file

import QtQuick
import Clayground.Physics
import Clayground.Svg

IconBar {
    id: healthBar
    property Player observed: null
    height: observed ? observed.height * .5 : 1
    maxValue: player ? player.maxHealth: 1
    value: player ? player.health : 1
    setSource: "visuals/heart_avail"
    unsetSource: "visuals/heart_na"
}

