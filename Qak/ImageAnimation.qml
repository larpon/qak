import QtQuick 2.0

import Qak 1.0
import Qak.QtQuick 1.0 as QakQuick

/*
 *
 */
Entity {
    id: imageAnimation

    adaptSource: enabled

    property bool enabled: true

    property int defaultFrameDelay: 60

    property var sequences: []

    readonly property var inc: Incubator.get()

    onSequencesChanged: {
        Qak.log('Reading sequences')
        state.sequenceNameIndex = {}
        for(var i in sequences) {
            var s = sequences[i]
            // TODO validate

            state.sequenceNameIndex[s.name] = i
        }
        animControl.canRun = true
    }

    QtObject {
        id: state

        property Image currentFrame
        property int currentFrameIndex: 1
        property int currentSequenceFrameIndex: 0
        property int currentFrameDelay: defaultFrameDelay

        property int activeSequenceIndex: 0
        property var activeSequence

        property var sequenceNameIndex: ({})

        property int totalAmountOfFrames: 0
        property int framesStartFrom: 0
        property int fileStringPadding: 0
        property string replacer: ""

    }




    function setActiveSequence(name) {
        animControl.stop()

        if(!name in state.sequenceNameIndex) {
            error('Can\'t find sequence named',name)
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

        //Qak.db('New active sequence',activeSequence.name)

        //state.currentFrame = frameContainer.children[state.currentFrameIndex]
        //repeater.itemAt(state.currentFrameIndex)

        animControl.restart()
    }

    Timer {
        id: animControl
        interval: state.currentFrameDelay
        repeat: true
        running: !imageAnimation.pause && !pause && canRun && frameContainer.balanced
        //triggeredOnStart: true

        property bool canRun: false
        property bool pause: false

        onTriggered: {

            // For inital frame
            if(!state.activeSequence) {
                state.activeSequence = sequences[state.activeSequenceIndex]
            }

            // Show the active frame
            //Qak.db('Now playing',activeSequence.name,'at frame index',currentFrameIndex)

            //state.currentFrame = frameContainer.children[state.currentFrameIndex]
                    //repeater.itemAt(state.currentFrameIndex)

            // Figure out next frame
            if('frames' in state.activeSequence && Object.prototype.toString.call( state.activeSequence.frames ) === '[object Array]') {

                // TODO reverse support
                /*
                if('reverse' in activeSequence && activeSequence.reverse && !('isReversed' in activeSequence)) {
                    Qak.db('Reversing')
                    activeSequence.frames = activeSequence.frames.reverse()
                    activeSequence.isReversed = true
                }
                */

                var endSequenceFrameIndex = state.activeSequence.frames[state.activeSequence.frames.length-1]

                if(state.currentFrameIndex == endSequenceFrameIndex) {
                    //Qak.db('End of sequence',activeSequence.name,'at index',currentSequenceFrameIndex,'- Deciding next sequence...')

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

                        //Qak.db('Next sequence',nSeq,'('+activeSequenceIndex+')','weight',totalWeight,'randInt',randInt)
                        setActiveSequence(nSeq)

                    }

                } else
                    state.currentSequenceFrameIndex++

                state.currentFrameIndex = state.activeSequence.frames[state.currentSequenceFrameIndex]

            } else {
                error('No frames. Skipping...')
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
        return count
    }

    function detectSourceType() {
        if(!enabled)
            return

        //error = false
        //ignore = false

        if(!adaptiveSource || adaptiveSource === "") {
            Qak.db('ImageAnimation',imageAnimation,'Empty source given')
            return
        }

        // Match any '.<digit>.' entries
        var match = adaptiveSource.match('(\\.?\\d+?\\.)')
        match = match ? match[1] : false

        if(match !== false) {
            var number = match.replace('.', '')
            state.replacer = number

            var padding = countPad(number)
            state.fileStringPadding = padding

            var digit = parseInt(number,10)
            state.framesStartFrom = digit

            var count = 0
            var nextSource = adaptiveSource


            while(Qak.resource.exists(nextSource)) {
                inc.later(imageComponent, frameContainer, {'frame':(count+digit),'source':nextSource,'state':state} )

                count++

                var next = pad((digit+count),padding)
                nextSource = adaptiveSource.replace(number, next)

            }
            inc.incubate()
            var lastFrameSource = adaptiveSource.replace(number, pad(count,padding))

            state.totalAmountOfFrames = count

            Qak.log('ImageAnimation','Assuming animation source based on','"'+number+'"','has',count,'frames','first frame',adaptiveSource,'last frame',lastFrameSource,'file name has padding',padding)

        } else {
            Qak.log('ImageAnimation','Assuming single image source')
            //enabled = false
            return
        }

        //mapSource = path
    }

    Component {
        id: imageComponent
        QakQuick.Image {
            id: image

            Component.onCompleted: {
                Qak.log('Component Image',state,'frame',frame,'source',source)
            }

            width: parent.width
            height: parent.height
            //source: adaptiveSource.replace(state.replacer, pad(frame,state.fileStringPadding))
            sourceSize: Qt.size(width,height)

            //opacity: image == state.currentFrame ? 1 : 0
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
        property bool balanced: state.totalAmountOfFrames === children.length
    }

    /*
    Repeater {
       id: repeater
       model: state.totalAmountOfFrames

       QakQuick.Image { // <- QakQuick Image
           id: image

           //asynchronous: true

           Component.onCompleted: {
               Qak.log('Repeater Image',state.totalAmountOfFrames,state.replacer,'idx',index,'framesStartFrom',state.framesStartFrom,'fileStringPadding',state.fileStringPadding)
           }

           width: imageAnimation.width
           height: imageAnimation.height
           source: adaptiveSource.replace(state.replacer, pad(index+state.framesStartFrom,state.fileStringPadding))
           sourceSize: Qt.size(width,height)
           opacity: image == state.currentFrame ? 1 : 0

           // Fun "motion blur"-ish effect
           //Behavior on opacity {
           //    NumberAnimation { duration: 100 }
           //}

           //property int frame: index+1
       }
   }
   */

}
