// (c) serein.pfeiffer@gmail.com - zlib license, see "LICENSE" file

import QtQuick
import Clayground.Svg
import Clayground.Common

import "details"

Item
{
    property var _svgProviders: new Map()

    function scene(name){
        return "scene/"  + name + ".svg"
    }

    Component{id: _svgProvider; SvgImageSource{annotationRRGGBB:"ff8080"}}
    function visual(path){
        if (path === "") return "";
        let parts = path.split("/");
        if (parts.length !== 2) {
            console.error("Got " + path + " but visual needs to be set like <svgName>/<elementId>.");
            return "";
        }
        let svg = parts[0];
        if (svg === "") return "";
        if (!_svgProviders.has(svg)){
            _svgProviders.set(svg, _svgProvider.createObject(this,  {svgPath: "visual/" + svg}));
        }
        let elId = parts[1];
        parts = Qt.locale().name.split("_");
        let obj = elId + "_" + parts[0];

        let provider = _svgProviders.get(svg);
        if (!provider.has(obj)) obj = elId;
        return provider.source(obj);
    }

    function sound(name){
        return name.length ? Clayground.resource("sound/" + name +  (name.endsWith("_music") ? ".mp3" : ".wav")) : "";
    }

    function text(str) {
        let key = Qt.locale().name;
        if(!_translations.has(key)) key = cLOCALE_ENGLISH_US;
        let translMap = _translations.get(key);
        if (!translMap.has(str)) return str;
        return translMap.get(str);
    }

    // Ids of translatable texts
    readonly property string cSTR_APP_NAME: "APP_NAME"
    readonly property string cSTR_APP_DESCR: "APP_DESCR"
    readonly property string cSTR_APP_HOMEPAGE: "APP_HOMEPAGE"
    readonly property string cSTR_GET_READY: "GET_READY"
    readonly property string cSTR_THE_END: "THE_END"
    readonly property string cCHOOSE_YOUR_SETTINGS: "CHOOSE_SETTINGS"

    // List of supported Locales
    readonly property string cLOCALE_ENGLISH_US: "en_US"

    // Define long text translations outside the translation
    // dictionary and just use the consts then
    readonly property string _STR_APP_DESCR_EN_US:
"
Enter the description of the app here.
"

    readonly property var _translations: new Map([

       // Add one entry for each locale
       [
           cLOCALE_ENGLISH_US,
           new Map(
                 [
                  [cSTR_APP_NAME, "MyGame"],
                  [cSTR_APP_DESCR, _STR_APP_DESCR_EN_US],
                  [cSTR_APP_HOMEPAGE, "www.mygame.com"],
                  [cCHOOSE_YOUR_SETTINGS, "Choose your Settings."],
                  [cSTR_GET_READY, "Get Ready!"],
                  [cSTR_THE_END, "The End ..."]
                 ]
           )
       ]

       ])

}

