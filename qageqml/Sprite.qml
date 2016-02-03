import QtQuick 2.5

import "./" as Qage
/*
 *
 */
Entity {
    id: sprite

    useAdaptiveSource: !enabled

    property bool enabled: true

    property string prefix: ""

    property bool ignore: false

    property bool error: false

    property Image currentFrame
    property int currentFrameIndex: 0

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

    SequentialAnimation {
        running: true
        ScriptAction {
            script: {
                currentFrame = repeater.itemAt(currentFrameIndex)

                currentFrameIndex++
                if(currentFrameIndex >= repeater.count-1)
                    currentFrameIndex = 0
            }
        }

        //PropertyAction { target: currentFrame; property: "visible"; value: false; }
        //PropertyAction { target: currentFrame; property: "visible"; value: false; }
        PauseAnimation { duration: 50 }

        loops: Animation.Infinite
    }

    function pad(number, digits) {
        return new Array(Math.max(digits - String(number).length + 1, 0)).join(0) + number
    }

    onSourceChanged: {
        if(!enabled)
            return

        error = false
        ignore = false

        if(source == "" || !source) {
            db(sprite,'Empty source given')
            return
        }

        var path = getSourceStepURL(0)

        if(!resource.exists(path)) {
            warn('No resource',path,'found. Ignoring')
            error = true
            ignore = true
            return
        }

        // Match any '.<digit>.' entries
        var match = source.match('(\\.?\\d+?\\.)')
        match = match ? match[1] : false

        if(match !== false) {
            var number = match.replace('.', '')
            var digit = parseInt(number,10)
            var next = pad((digit+1),number.length)
            var nextMatch = source.replace(number, next)
            //nextMatch =
            log('Assuming animation source based on','"'+number+'"',nextMatch)
        } else {
            log('Assuming single image source')
            enabled = false
            return
        }

        //mapSource = path

    }

    Repeater {
       id: repeater
       model: 10
       Qage.Image {
           id: image
           width: sprite.width
           height: sprite.height
           source: "sitting_man/" + pad((index+1),4) + ".png"
           sourceSize: Qt.size(width,height)
           visible: image == currentFrame
           property int frame: index+1
       }
   }
}
