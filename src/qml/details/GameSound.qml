// (c) serein.pfeiffer@gmail.com - zlib license, see "LICENSE" file

import QtQuick
import QtMultimedia
import Clayground.Common

SoundEffect {
    property string sound: ""
    muted: gameState.muteSound
    source: assets.sound(sound)
}
