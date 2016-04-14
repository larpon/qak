import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0
import Qak.QtQuick 1.0 as QakQuick

/*
 *
 */
Entity {
    id: imageAnimation

    adaptSource: enabled

    property bool enabled: true

    property bool running: true

    property int defaultFrameDelay: 60

    property var sequences: []

    onSequencesChanged: {
        //Qak.debug('ImageAnimation','reading sequences')
        animControl.canRun = false
        state.sequenceNameIndex = {}
        for(var i in sequences) {
            var s = sequences[i]
            // TODO validate each sequence object
            state.sequenceNameIndex[s.name] = i

            if('reverse' in s && s.reverse && ('frames' in s && Object.prototype.toString.call( s.frames ) === '[object Array]')) {
                //Qak.debug('ImageAnimation','reversing',s.name)
                sequences[i].frames = sequences[i].frames.reverse()
            }
        }
        animControl.canRun = true
    }

    QtObject {
        id: state

        property int currentFrameIndex: 1
        property int currentSequenceFrameIndex: 0
        property int currentFrameDelay: defaultFrameDelay

        property int activeSequenceIndex: 0
        property var activeSequence

        property string nextActiveSequence: ""

        property var sequenceNameIndex: ({})

        property int totalAmountOfFrames: 0

        readonly property var inc: Incubator.get()

        function reset() {
            //Qak.debug('ImageAnimation','state reset')
            currentFrameIndex = 1
            currentSequenceFrameIndex = 0
            currentFrameDelay = defaultFrameDelay
            activeSequenceIndex = 0
            activeSequence = undefined
            sequenceNameIndex = {}
            totalAmountOfFrames = 0
        }
    }

    function restart() {
        reset()

        state.totalAmountOfFrames = frameContainer.children.length

        running = true

        var tmpSequneces = sequences
        sequences = tmpSequneces
    }

    function reset() {
        //Qak.debug('ImageAnimation','reset')

        state.reset()

        animControl.canRun = false

    }

    function setActiveSequence(name) {
        animControl.stop()

        if(!name in state.sequenceNameIndex) {
            Qak.error('Can\'t find sequence named',name)
            return
        }

        state.activeSequenceIndex = state.sequenceNameIndex[name]
        state.activeSequence = sequences[state.activeSequenceIndex]
        state.currentSequenceFrameIndex = 0
        if('frames' in state.activeSequence && Object.prototype.toString.call( state.activeSequence.frames ) === '[object Array]') {
            state.currentFrameIndex = state.activeSequence.frames[state.currentSequenceFrameIndex]
        }

        // Figure out frame delay
        if('duration' in state.activeSequence) {
            // NOTE TODO TIMER? once the animation is started parameters can't be changed on it
            // So if anything changes the animation must be restarted
            if(state.currentFrameDelay != state.activeSequence.duration)
                state.currentFrameDelay = state.activeSequence.duration
        } else {
            if(state.currentFrameDelay != defaultFrameDelay)
                state.currentFrameDelay = defaultFrameDelay
        }

        //Qak.debug('ImageAnimation','active sequence is now',state.activeSequence.name)

        animControl.restart()
    }

    Timer {
        id: animControl
        interval: state.currentFrameDelay
        //onIntervalChanged: Qak.debug('ImageAnimation','animControl','interval',interval)
        repeat: true
        running: !paused && canRun && frameContainer.balanced
        //triggeredOnStart: true

        property bool canRun: false
        property bool paused: imageAnimation.paused || !imageAnimation.running

        onTriggered: {

            // For inital frame
            if(!state.activeSequence) {
                state.activeSequence = sequences[state.activeSequenceIndex]

                if(state.activeSequence === undefined) {
                    Qak.error('No active sequence can be set. Stopping...')
                    imageAnimation.running = false
                    return
                }
            }

            // If instructed to set a new active sequences
            if(state.nextActiveSequence != '') {
                //Qak.debug('Next sequence',nSeq,'('+activeSequenceIndex+')','weight',totalWeight,'randInt',randInt)
                setActiveSequence(state.nextActiveSequence)
                state.nextActiveSequence = ""
            }

            // Show the active frame
            state.currentFrameIndex = state.activeSequence.frames[state.currentSequenceFrameIndex]
            //Qak.debug('ImageAnimation','showing',state.activeSequence.name,'at frame index',state.currentFrameIndex,'current sequence frame index',state.currentSequenceFrameIndex)

            // Figure out next frame
            if('frames' in state.activeSequence && Object.prototype.toString.call( state.activeSequence.frames ) === '[object Array]') {

                // TODO optimize
                var endSequenceFrameIndex = state.activeSequence.frames.length-1

                if(state.currentSequenceFrameIndex == endSequenceFrameIndex) {
                    //Qak.debug('ImageAnimation','end of sequence',state.activeSequence.name,'at index',state.currentSequenceFrameIndex,'- Deciding next sequence...')

                    if('to' in state.activeSequence) {
                        var seqTo = state.activeSequence.to
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

                        // Instruct state to setActiveSequence() next run
                        state.nextActiveSequence = nSeq

                    } else { // missing to: {...} entry - stop
                        //Qak.debug('ImageAnimation','nowhere to go. Stopping...')
                        imageAnimation.running = false
                    }

                } else
                    state.currentSequenceFrameIndex++

            } else {
                Qak.error('No frames. Skipping...')
                imageAnimation.running = false
            }

        }

    }

    function pad(number, digits) {
        return new Array(Math.max(digits + 1 - String(number).length + 1, 0)).join(0) + number
    }

    function countPad(str) {
        var count = 0
        for (var i = 0, len = str.length; i < len; i++) {
            if(str[i] === '0')
                count++
            else
                break
        }
        // NOTE fixes a string with all zeroes e.g.: '0000'
        if(count == str.length)
            count--
        return count
    }

    function detectSourceType() {
        if(!enabled)
            return

        //error = false
        //ignore = false

        if(!adaptiveSource || adaptiveSource === "") {
            Qak.warn('ImageAnimation',imageAnimation,'Empty source given')
            return
        }

        // Match any '.<digit>.' entries
        var match = adaptiveSource.match('(\\.?\\d+?\\.)')
        match = match ? match[1] : false

        if(match !== false) {
            var number = match.replace(new RegExp('\\.', 'g'), '')
            //state.replacer = number

            var padding = countPad(number)
            //state.fileStringPadding = padding

            var digit = parseInt(number,10)
            //state.framesStartFrom = digit

            var frame = 1
            var nextSource = adaptiveSource

            // TODO fix this (async = true (which is default) doesn't work in HammerBees?)
            state.inc.async = false
            while(Qak.resource.exists(nextSource)) {
                state.inc.later(imageComponent, frameContainer, {'frame':frame,'source':nextSource,'state':state} )
                frame++
                digit++

                var next = pad((digit),padding)
                nextSource = adaptiveSource.replace(number, next)

            }
            state.inc.incubate()
            var lastFrameSource = adaptiveSource.replace(number, pad(frame,padding))

            state.totalAmountOfFrames = frame-1

            //Qak.debug('ImageAnimation','Assuming animation source based on match','"'+match+'"','number','"'+number+'"','has',frame,'frames','first frame',adaptiveSource,'last frame',lastFrameSource,'file name has padding',padding)

        } else {
            Qak.warn('ImageAnimation','Assuming single image source')
            //enabled = false
            return
        }

        //mapSource = path
    }

    Component {
        id: imageComponent
        QakQuick.Image {
            id: image

            /*
            Component.onCompleted: {
                Qak.log('Component Image',state,'frame',frame,'source',source)
            }
            */

            width: parent.width
            height: parent.height
            //source: adaptiveSource.replace(state.replacer, pad(frame,state.fileStringPadding))
            sourceSize: Qt.size(width,height)

            opacity: frame === state.currentFrameIndex ? 1 : 0

            property int frame: 0
            property var state

            // Fun "motion blur"-ish effect
            //Behavior on opacity {
            //    NumberAnimation { duration: 100 }
            //}
        }
    }

    onAdaptiveSourceChanged: {
        detectSourceType()
    }

    Item {
        anchors.fill: parent
        id: frameContainer
        property bool balanced: children.length > 0 && state.totalAmountOfFrames === children.length
    }

}
