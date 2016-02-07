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
    property int currentSequenceFrameIndex: 0
    property int currentFrameDelay: defaultFrameDelay
    property int defaultFrameDelay: 40

    property int activeSequenceIndex: 0
    property var activeSequence

    property var sequences: [
        {
            name: "sit",
            frames: [1,2,3,4,5,6],
            duration: 1000,
            to: { "sit": 1, "sit > look_back": 1, "sit > reach": 1 }
        },
        {
            name: "sit > reach",
            frames: [1,2,3,4,5,6],
            to: { "reach > sit": 1 }
        },
        {
            name: "reach > sit",
            frames: [6,5,4,3,2,1],
            to: { "sit": 1 }
        },
        {
            name: "sit > look_back",
            frames: [20,21,22,23,24],
            to: { "look_back > sit":1 }
        },
        {
            name: "look_back > sit",
            frames: [24,23,22,21,20],
            to: { "sit":1 }
        }
    ]

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
        id: animControl
        running: true
        ScriptAction {
            script: {
                // TODO more sanity checks
                if('length' in sequences && sequences.length > 0) {
                    activeSequence = sequences[activeSequenceIndex]
                    if(!activeSequence)
                        error('ActiveSequence is bullshit')
                } else {
                    error('Sprite','something wrong')
                    return
                }

                // Figure our how long this frame should show
                if('duration' in activeSequence) {
                    // NOTE TODO once the animation is started parameters can't be changed on it
                    // So if anything changes the animation must be restarted
                    if(currentFrameDelay != activeSequence.duration) {
                        currentFrameDelay = activeSequence.duration
                        animControl.restart()
                    }
                } else
                    currentFrameDelay = defaultFrameDelay

                // Show the frame
                currentFrame = repeater.itemAt(currentFrameIndex)

                // Figure out next frame
                if('frames' in activeSequence && Object.prototype.toString.call( activeSequence.frames ) === '[object Array]') {

                    /* Logic

                    */

                    var endSequenceFrameIndex = activeSequence.frames[activeSequence.frames.length-1]

                    currentSequenceFrameIndex++

                    if(currentSequenceFrameIndex == endSequenceFrameIndex) {
                        currentSequenceFrameIndex = 0
                        //activeSequenceIndex++
                    }

                    //db(activeSequence,activeSequence.frames,currentSequenceFrameIndex,endSequenceFrameIndex,activeSequence.frames[currentSequenceFrameIndex])
                    currentFrameIndex = activeSequence.frames[currentSequenceFrameIndex]
                } else
                    currentFrameIndex++

                if(currentFrameIndex >= repeater.count-1 || currentFrameIndex < 0) {
                    currentFrameIndex = 0
                    warn('Corrected currentFrameIndex')
                }

                //db('Sprite','next frame',currentFrameIndex)
            }
        }

        //PropertyAction { target: currentFrame; property: "visible"; value: false; }
        //PropertyAction { target: currentFrame; property: "visible"; value: false; }
        PauseAnimation { duration: currentFrameDelay }

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
       model: 24
       Qage.Image {
           id: image
           width: sprite.width
           height: sprite.height
           source: "sitting_man/" + pad((index+1),4) + ".png"
           sourceSize: Qt.size(width,height)
           visible: image == currentFrame
           //property int frame: index+1
       }
   }

}
