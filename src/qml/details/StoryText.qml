import QtQuick 2.0

Text {
    id: _text

    function tell(){}
    readonly property bool telling: visible

    font.family: "Monospace"
    property var story: []

    property int _index: -1
    readonly property bool _validIdx: _index < story.length
    readonly property int _displayDuration: _validIdx ? story[_index].duration : 0
    readonly property int _pauseDuration: _validIdx ? story[_index].pause : 0
    readonly property int _fadeDuration: _validIdx && story[_index].fade ?  story[_index].fade : 750

    Component.onCompleted: _nextText()
    onTextChanged: _textAnim.start()
    function _nextText(){
        _index ++;
        if (_index < story.length)
            text = story[_index].text;
        else
            visible = false;
    }

    SequentialAnimation{
        id: _textAnim
        NumberAnimation { target: _text; property: "opacity"; from: 0; to: 1; duration: _text._fadeDuration }
        PauseAnimation {duration: _text._displayDuration}
        NumberAnimation { target: _text; property: "opacity"; from: 1; to: 0; duration: _text._fadeDuration }
        PauseAnimation {duration: _text._pauseDuration}
        onRunningChanged: if (!running) _text._nextText();
    }
}
