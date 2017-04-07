import QtQuick 2.0

import Qak 1.0

QtObject {

    property bool enabled: true

    property string source: ""
    property string mapSource

    property Item assetMultiplierSource
    property int assetMultiplierStep: 2
    readonly property int assetMultiplier: Math.floor((assetMultiplierSource ? assetMultiplierSource.assetMultiplier : Qak.assetMultiplier) / assetMultiplierStep) * assetMultiplierStep

    property Item target
    property string targetSourceProperty: "source"

    property bool ignore: false

    property bool error: false

    Component.onCompleted: detectMapSource()

    function setMapSource(step) {

        var src = getSourceStepURL(step)

        var tryLimit = 4
        var tries = 0

        // TODO MAYBE optimize some day to remember the found resource for the given step?
        while(!Qak.resource.exists(src) && tries < tryLimit) {

            if(step > 0)
                step = step - assetMultiplierStep
            else
                step = step + assetMultiplierStep

            src = getSourceStepURL(step)

            //Qak.debug('Tri',tries+1,'of',tryLimit,'to find','"x'+step+'"','resource for',source)

            tries++
        }

        if(Qak.resource.exists(src) && mapSource != src) {
            mapSource = src
        }/* else
            Qak.warn('Nothing found for',source,'at steps till',step)
            */
    }

    function getSourceStepURL(step) {
        var src = ""

        if(step == 0) {
            src = source
        } else {
            src = source.substring(0, source.lastIndexOf(".")) + ".x" + step + source.substring(source.lastIndexOf("."))
        }

        return src
    }

    onTargetChanged: {
        if(target && mapSource !== "") {
//            Qak.debug(Qak.gid+'AdaptiveSource',target,'Target available. Resource mapping for source','"'+source+'"','is now','"'+mapSource+'"') //¤qakdbg
            target[targetSourceProperty] = mapSource
        }
    }


//    onEnabledChanged: {
//        if(enabled) {
//            //target[targetSourceProperty] = mapSource
//        }
//    }

    function detectMapSource() {

        if(!enabled)
            return

        error = false
        ignore = false

        if(source == "" || !source) {
//            Qak.debug(Qak.gid+'AdaptiveSource','source for target',target,'is empty') //¤qakdbg
            return
        }

        var path = getSourceStepURL(0)

        if(!Qak.resource.exists(path)) {
            Qak.warn('AdaptiveSource','No resource',path,'found. Ignoring')
            error = true
            ignore = true
            return
        }

        // Match any '.x<int>.' entries
        var match = source.match('\\.(x-?.+?)\\.')
        match = match ? match[1] : false
        if(match !== false) {
            Qak.warn('AdaptiveSource','Request for specific',match,'mapped source. Ignoring auto mapping')
            mapSource = path
            ignore = true
        }

        mapSource = path
    }

    onSourceChanged: {
        detectMapSource()
    }

    onMapSourceChanged: {
        if(!enabled || ignore || error)
            return

        if(target) {
//            Qak.debug(Qak.gid+'AdaptiveSource',target,'Resource mapping for source','"'+source+'"','is now','"'+mapSource+'"') //¤qakdbg
            target[targetSourceProperty] = mapSource
        }// else
         //   Qak.warn('AdaptiveSource','"target" property is not yet sat for',source)
    }

    onAssetMultiplierChanged: {
        if(!enabled || ignore || error)
            return
        setMapSource(assetMultiplier)
    }

}
