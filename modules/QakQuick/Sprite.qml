import QtQuick 2.5

import QakQuick 1.0
import QakQuick.QtQuick 1.0 as QakQt
/*
 *
 */
Entity {
    id: sprite

    adaptSource: !enabled

    property bool enabled: true

    property string prefix: ""

    property bool ignore: false

    property bool error: false


    property Image currentFrame
    property int currentFrameIndex: 0
    property int currentSequenceFrameIndex: 0
    property int currentFrameDelay: defaultFrameDelay
    property int defaultFrameDelay: 60

    property int activeSequenceIndex: 0
    property var activeSequence

    // TODO
    property var sequenceNameIndex: {
        "sit":0,
        "sit > reach":1,
        "reach > sit":2,
        "sit > look_back":3,
        "look_back > sit":4
    }

    property var sequences: [
        {
            name: "sit",
            frames: [0],
            duration: 2000,
            to: { "sit": 1, "sit > look_back": 2, "sit > reach": 3 }
        },
        {
            name: "sit > reach",
            //duration: 100,
            frames: [0,1,2,3,4,5,6,7,8],
            to: { "reach > sit": 1 }
        },
        {
            name: "reach > sit",
            //duration: 100,
            //reverse: true,
            //frames: [0,1,2,3,4,5,6,7,8],
            frames: [8,7,6,5,4,3,2,1,0],
            to: { "sit": 1 }
        },
        {
            name: "sit > look_back",
            //duration: 100,
            frames: [19,20,21,22,23],
            to: { "look_back > sit":1 }
        },
        {
            name: "look_back > sit",
            //duration: 100,
            frames: [23,22,21,20,19],
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

    function setActiveSequence(name) {
        animControl.stop()

        if(!name in sequenceNameIndex) {
            error('Can\'t find sequence named',name)
            return
        }

        activeSequenceIndex = sequenceNameIndex[name]
        activeSequence = sequences[activeSequenceIndex]
        currentSequenceFrameIndex = 0
        if('frames' in activeSequence && Object.prototype.toString.call( activeSequence.frames ) === '[object Array]') {
            currentFrameIndex = activeSequence.frames[currentSequenceFrameIndex]
        }

        // Figure out frame delay
        if('duration' in activeSequence) {
            // NOTE TODO TIMER? once the animation is started parameters can't be changed on it
            // So if anything changes the animation must be restarted
            if(currentFrameDelay != activeSequence.duration)
                currentFrameDelay = activeSequence.duration
        } else {
            if(currentFrameDelay != defaultFrameDelay)
                currentFrameDelay = defaultFrameDelay
        }

        //Qak.db('New active sequence',activeSequence.name)

        currentFrame = repeater.itemAt(currentFrameIndex)

        animControl.restart()
    }

    Timer {
        id: animControl
        interval: currentFrameDelay
        repeat: true
        running: !sprite.pause && !pause
        //triggeredOnStart: true

        property bool pause: false

        onTriggered: {

            // For inital frame
            if(!activeSequence) {
                activeSequence = sequences[activeSequenceIndex]
            }

            // Show the active frame
            //Qak.db('Now playing',activeSequence.name,'at frame index',currentFrameIndex)
            currentFrame = repeater.itemAt(currentFrameIndex)

            // Figure out next frame
            if('frames' in activeSequence && Object.prototype.toString.call( activeSequence.frames ) === '[object Array]') {

                // TODO reverse support
                /*
                if('reverse' in activeSequence && activeSequence.reverse && !('isReversed' in activeSequence)) {
                    Qak.db('Reversing')
                    activeSequence.frames = activeSequence.frames.reverse()
                    activeSequence.isReversed = true
                }
                */

                var endSequenceFrameIndex = activeSequence.frames[activeSequence.frames.length-1]

                if(currentFrameIndex == endSequenceFrameIndex) {
                    //Qak.db('End of sequence',activeSequence.name,'at index',currentSequenceFrameIndex,'- Deciding next sequence...')

                    if('to' in activeSequence) {
                        var seqTo = activeSequence.to
                        var nSeq = ""
                        var totalWeight = 0, cumWeight = 0
                        for(var seqName in seqTo) {
                            totalWeight += seqTo[seqName]
                        }
                        var randInt = Math.floor(Math.random()*totalWeight)

                        for(seqName in seqTo) {
                            cumWeight += seqTo[seqName]
                            if (randInt < cumWeight) {
                                nSeq = seqName
                                break;
                            }

                        }

                        //Qak.db('Next sequence',nSeq,'('+activeSequenceIndex+')','weight',totalWeight,'randInt',randInt)
                        setActiveSequence(nSeq)

                    }

                } else
                    currentSequenceFrameIndex++

                currentFrameIndex = activeSequence.frames[currentSequenceFrameIndex]

            } else {
                error('No frames. Skipping...')
            }

        }

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
            Qak.db(sprite,'Empty source given')
            return
        }

        var path = getSourceStepURL(0)

        if(!resource.exists(path)) {
            Qak.warn('No resource',path,'found. Ignoring')
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
            Qak.log('Assuming animation source based on','"'+number+'"',nextMatch)
        } else {
            Qak.log('Assuming single image source')
            enabled = false
            return
        }

        //mapSource = path

    }

    Repeater {
       id: repeater
       model: 24
       QakQt.Image { // <- QakQuick Image
           id: image

           asynchronous: true

           width: sprite.width
           height: sprite.height
           source: "sitting_man/" + pad((index+1),4) + ".png"
           sourceSize: Qt.size(width,height)
           opacity: image == currentFrame ? 1 : 0

           // Fun "motion blur"-ish effect
           //Behavior on opacity {
           //    NumberAnimation { duration: 100 }
           //}

           //property int frame: index+1
       }
   }

}
