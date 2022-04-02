// (c) serein.pfeiffer@gmail.com - zlib license, see "LICENSE" file

import QtQuick
import Clayground.Physics
import Clayground.Svg

Row {
    id: iconBar

    property int maxValue: 0
    property int value: 0
    property string setSource: ""
    property string unsetSource: ""
    spacing: 5

    Repeater {
        model: maxValue
        Item {
            height: iconBar.height
            width: height
            Image {
                id: _avail
                anchors.fill: parent
                source: assets.visual(iconBar.setSource)
                visible: index < value
            }
            Image {
                anchors.fill: parent
                source: assets.visual(iconBar.unsetSource)
                visible: !_avail.visible
            }
        }
    }
}

