import QtQuick
import QtQuick.Controls

import "details"

Rectangle {
    color: gameState.screenBgColor
    Row {
        id: headline
        GameButton {
            id: _backBtn
            width: gameState.btnWidth * .75
            sourcePath: "visuals/btn_back"
            onClicked: gameApp.transitionTo(titleScreenComp)
        }
    }

    Flickable {
        id: infoScreen
        interactive: true
        anchors.top: headline.bottom
        width: parent.width - anchors.leftMargin
        height: parent.height - y
        ScrollBar.vertical: ScrollBar{}
        contentHeight: _scrollableContent.height

        anchors.left: parent.left
        anchors.leftMargin: parent.width * .05


        Column {
            id: _scrollableContent
            spacing: parent.width * .008

            Row {
                spacing: .1 * _headline.height

                Column {
                    id: _headline
                    Text {
                        text: assets.text(assets.cSTR_APP_NAME)
                        font.pixelSize: _backBtn.height * .5
                        MouseArea {
                            anchors.fill: parent
                            property int numClicks: 0
                            onClicked: { numClicks++; if (numClicks === 5) {gameState.unlockAll(); parent.font.bold = true;}}
                        }
                    }

                    Text {text: assets.text(assets.cSTR_APP_HOMEPAGE)}
                }
            }
            TextArea {
                width: infoScreen.width
                readOnly: true
                wrapMode: Text.WordWrap
                text: assets.text(assets.cSTR_APP_DESCR)
            }
            Loader {sourceComponent: licenseText; asynchronous: true}
            Component {
                id: licenseText
                TextArea {
                    width: infoScreen.width
                    wrapMode: Text.WordWrap
                    readOnly: true
                    text:
"
Pre-formatted license texts go here.
"
            }
}

}
}
}
