import QtQuick 2.5

import QakQuick 1.0

QtObject {

    property bool enabled: true

    property string source: ""
    property string mapSource

    property int assetMultiplierStep: 2
    readonly property int assetMultiplier: Math.floor(Qak.assetMultiplier / assetMultiplierStep) * assetMultiplierStep

    property Item target
    property string targetSourceProperty: "source"

    property string prefix: ""

    property bool ignore: false

    property bool error: false

    /*
    function asset(path) {
        var assetPath = "assets/"+path
        var filename = path.replace(/^.*[\\\/]/, '')

        if(core.platform.isDesktop && core.platform.isDebugBuild) {
            path = 'file:///home/lmp/Projects/HammerBees/HammerBees/assets/'+path
        } else {
            if(core.platform.isAndroid)
                path = "assets:/"+path
            else if(core.platform.isMac && endsWith(path,'.mp3'))
                path = 'file://'+core.resource.appPath()+'/'+path
            else
                path = 'qrc:///'+assetPath
        }

        if(!core.resource.exists(path)) {
            if(filename.indexOf("*") > -1)
                Qak.warn('Wildcard asset',path)
            else
                Qak.error('Invalid asset',path)
        }
        //else
        //    Qak.info('Asset',path)

        return path
    }
    */

    function setMapSource(step) {

        var src = getSourceStepURL(step)

        var tryLimit = 4
        var tries = 0

        // TODO MAYBE optimize some day to remember the found resource for the given step?
        while(!resource.exists(src) && tries < tryLimit) {

            if(step > 0)
                step = step - assetMultiplierStep
            else
                step = step + assetMultiplierStep

            src = getSourceStepURL(step)

            //Qak.db('Tri',tries+1,'of',tryLimit,'to find','"x'+step+'"','resource for',source)

            tries++
        }

        if(resource.exists(src) && mapSource != src) {
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

        var pfx = ""
        if(prefix !== '')
            pfx = prefix.replace(/\/+$/, "")+"/"

        // TODO do platform asset protocol control etc..
        if(src && src != "")
            src = "qrc:///"+pfx+src

        return src
    }

    onTargetChanged: {
        if(target) {
            Qak.db(target,'Target available. Resource mapping for source','"'+source+'"','is now','"'+mapSource+'"')
            target[targetSourceProperty] = mapSource
        }
    }

    onEnabledChanged: {
        //if(enabled)

    }

    onSourceChanged: {

        if(!enabled)
            return

        error = false
        ignore = false

        if(source == "" || !source) {
            mapSource = undefined
            Qak.db(sourceEntity,'Empty source given')
            return
        }

        var path = getSourceStepURL(0)

        if(!resource.exists(path)) {
            Qak.warn('No resource',path,'found. Ignoring')
            error = true
            ignore = true
            return
        }

        // Match any '.x<int>.' entries
        var match = source.match('\\.(x-?.+?)\\.')
        match = match ? match[1] : false
        if(match !== false) {
            Qak.warn('Request for specific',match,'mapped source. Ignoring auto mapping')
            mapSource = path
            ignore = true
        }

        mapSource = path
    }

    onMapSourceChanged: {
        if(!enabled || ignore || error)
            return

        if(target) {
            Qak.log(target,'Resource mapping for source','"'+source+'"','is now','"'+mapSource+'"')
            target[targetSourceProperty] = mapSource
        } else
            Qak.warn('"target" property is not yet sat for',source)
    }

    onAssetMultiplierChanged: {
        if(!enabled || ignore || error)
            return
        setMapSource(assetMultiplier)
    }

}
