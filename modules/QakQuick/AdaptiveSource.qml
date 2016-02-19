import QtQuick 2.5
import QtQml 2.2
import QtQuick.Window 2.2 // Screen

QtObject {

    property bool enabled: true

    property string source: ""
    property string mapSource

    property int assetMultiplierStep: 2
    readonly property int assetMultiplier: Math.floor(core.assetMultiplier / assetMultiplierStep) * assetMultiplierStep

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
                core.warn('Wildcard asset',path)
            else
                core.error('Invalid asset',path)
        }
        //else
        //    core.info('Asset',path)

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

            //core.db('Tri',tries+1,'of',tryLimit,'to find','"x'+step+'"','resource for',source)

            tries++
        }

        if(resource.exists(src) && mapSource != src) {
            mapSource = src
        }/* else
            core.warn('Nothing found for',source,'at steps till',step)
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
            core.db(target,'Target available. Resource mapping for source','"'+source+'"','is now','"'+mapSource+'"')
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
            core.db(sourceEntity,'Empty source given')
            return
        }

        var path = getSourceStepURL(0)

        if(!resource.exists(path)) {
            core.warn('No resource',path,'found. Ignoring')
            error = true
            ignore = true
            return
        }

        // Match any '.x<int>.' entries
        var match = source.match('\\.(x-?.+?)\\.')
        match = match ? match[1] : false
        if(match !== false) {
            core.warn('Request for specific',match,'mapped source. Ignoring auto mapping')
            mapSource = path
            ignore = true
        }

        mapSource = path
    }

    onMapSourceChanged: {
        if(!enabled || ignore || error)
            return

        if(target) {
            core.log(target,'Resource mapping for source','"'+source+'"','is now','"'+mapSource+'"')
            target[targetSourceProperty] = mapSource
        } else
            core.warn('"target" property is not yet sat for',source)
    }

    onAssetMultiplierChanged: {
        if(!enabled || ignore || error)
            return
        setMapSource(assetMultiplier)
    }

}
