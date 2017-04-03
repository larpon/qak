import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0
import Qak.Private 1.0
import Qak.QtQuick 2.0

/*
 * TODO re-write in C++ - the code is a mess - running states are hard to use and predict
 * Remember to include access to the actual Component showed - see use of 'frames' property
 */
ItemAnimationPrivate {
    id: r

    default property alias content: _frames.data

    property bool paused: false
    property bool enabled: true

    running: true

    property alias property: _frames.property
    property alias on: _frames.on
    property alias off: _frames.off

    property int defaultFrameDelay: 60

    property var sequences: []
    property var __validSequences: []
    readonly property alias sequence: p.activeSequence
    readonly property alias sequenceName: p.currentActiveSequence

    readonly property alias balanced: _frames.balanced

    property Component delegate
    property int model: 0
    onModelChanged: {
        if(model <= 0 || !delegate)
            return

        p.spawnFrames()
    }

    onDelegateChanged: {
        if(model <= 0 || !delegate)
            return
        p.spawnFrames()
    }
    Component.onDestruction: p.clearFrames()

    property string goalSequence: ""

    property var frames: ({})
    readonly property alias count: p.totalAmountOfFramesSpawned

    property int frame: 1
    onFrameChanged: p.emitFrameSynced()

    onGoalSequenceChanged: {
        setGoalSequence()
    }

    function jumpTo(sequenceName) {
        frameTicker.stop()
        restart()
        setActiveSequence(sequenceName)
        frameTicker.restart()
    }

    function setGoalSequence() {
        if(!p.activeSequence)
            return

        if(goalSequence === "")
            return

        p.sequencePath = []

        var from = p.activeSequence.name
        var to = goalSequence

        var nodes = {}

        // Convert sequence items to nodes format with all costs set to 1
        // NOTE see aid.js for implementation and format
        for(var i in sequences) {
            var s = sequences[i]
            var sto = Aid.clone(s.to)
            for(var k in sto) {
                sto[k] = 1
            }
            nodes[s.name] = sto
        }

        // Calculate fastest route to goal sequence
        var route = Aid.findShortestPath(nodes,from,to)
        if(route === null) {
            Qak.error('ItemAnimation','No path from',from,'to',to,'ignoring goalSequence')
            return
        }

        if(route.length > 1 && route[0] === from) {
            //Qak.info('ItemAnimation','already at',from,'removing from path')
            route.shift()
        }

        /* // TODO This is fucking up situations where goalSequence is set during initialization
        if(route.length > 0 && route[0] === goalSequence) {
            Qak.info('ItemAnimation','already at goalSequence',goalSequence)
            goalSequenceReached()
            goalSequence = ""
            return
        }*/

//        Qak.debug('ItemAnimation','goalSequence',route.join(' -> ')) //¤qakdbg
        p.sequencePath = route
    }

    signal goalSequenceReached

    signal frameSynced(int frame, string sequenceName)

    signal restarted

    onSequencesChanged: {
//        Qak.debug('ItemAnimation','reading sequences') //¤qakdbg
        __validSequences = []
        frameTicker.ready = false
        p.sequenceNameIndex = {}
        for(var i in sequences) {
            var s = Aid.clone(sequences[i])

            // Validate sequence object
            if(!('frames' in s && Aid.isObject( s.frames )))
                continue

            // TODO validate each sequence object - or force use of some new QML type e.g. "SequenceItem" ??
            p.sequenceNameIndex[s.name] = i

            if('reverse' in s && s.reverse && ('frames' in s && Object.prototype.toString.call( s.frames ) === '[object Array]')) {
//                Qak.debug('ItemAnimation','reversing',s.name) //¤qakdbg
                s.frames = s.frames.reverse()
            }

            if('to' in s) {
                s.__toCum = {}
                var totalWeight = 0, cumWeight = 0
                for(var seqName in s.to) {
                    totalWeight += s.to[seqName]

                    if(s.to[seqName] <= 0)
                        continue

                    cumWeight += s.to[seqName]
                    s.__toCum[seqName] = cumWeight
                }
                s.toTotalWeight = totalWeight
            }

            __validSequences.push(s)
        }

        frameTicker.ready = true
    }

    QtObject {
        id: p

        property int sequenceFrameIndex: 0
        property int frameDelay: defaultFrameDelay

        property int activeSequenceIndex: 0
        property var activeSequence

        property string currentActiveSequence: ""
        property string nextActiveSequence: ""
        property var sequencePath: ([])

        property bool signalGoalSequenceReached: false

        property var sequenceNameIndex: ({})

        property int totalAmountOfFrames: _frames.children.length
        property int totalAmountOfFramesSpawned: 0


        function clearFrames() {
            for(var i in frames) {
                totalAmountOfFramesSpawned--
                frames[i].destroy()
            }
            frames = {}
        }

        function spawnFrames() {
            clearFrames()

            for(var i = 1; i <= model; i++) {
                Incubate.later(delegate, _frames, { frame: i }, function(o){
                    r.frames[o.frame+""] = o
                    totalAmountOfFramesSpawned++
                } )
            }
            Incubate.incubate()
        }


        function emitFrameSynced() {
            if(!activeSequence)
                frameSynced(r.frame, '')
            else
                frameSynced(r.frame, currentActiveSequence)
        }

        function reset() {
            //Qak.debug('ItemAnimation','state reset')
            sequenceFrameIndex = 0
            frameDelay = defaultFrameDelay
            activeSequenceIndex = 0
            activeSequence = undefined
            currentActiveSequence = ""
            nextActiveSequence = ""
            sequencePath = []
            signalGoalSequenceReached = false
            sequenceNameIndex = {}
            //totalAmountOfFramesSpawned = 0
        }
    }

    function restart() {
        reset()

        setRunning(true)

        var tmpSequneces = sequences
        sequences = tmpSequneces
        restarted()
    }

    function reset() {
        //Qak.debug('ItemAnimation','reset')

        p.reset()

        goalSequence = ""
        frameTicker.ready = false

    }

    function stop() {
        setRunning(false)
    }

    function start() {
        setRunning(true)
    }

    property alias __activeSequence: p.activeSequence
    function setActiveSequence(name) {
        frameTicker.stop()

        if(!(name in p.sequenceNameIndex)) {
            Qak.error('ItemAnimation','Can\'t find sequence named',name)
            return
        }

        p.activeSequenceIndex = p.sequenceNameIndex[name]
        __activeSequence = __validSequences[p.activeSequenceIndex]
        if('name' in __activeSequence) {
            p.currentActiveSequence = __activeSequence.name
        }
        p.sequenceFrameIndex = 0

        r.frame = __activeSequence.frames[p.sequenceFrameIndex]

        // Figure out frame delay
        if('duration' in __activeSequence) {
            // NOTE TODO TIMER? once the animation is started parameters can't be changed on it
            // So if anything changes the animation must be restarted
            if(p.frameDelay !== __activeSequence.duration)
                p.frameDelay = __activeSequence.duration
        } else {
            if(p.frameDelay != defaultFrameDelay)
                p.frameDelay = defaultFrameDelay
        }

        //Qak.debug('ItemAnimation','active sequence is now',state.activeSequence.name)

        frameTicker.restart()
    }

    Timer {
        id: frameTicker
        interval: p.frameDelay

        repeat: true
        running: r.running && !paused && ready && _frames.balanced

        property bool ready: false
        property bool paused: r.paused

        property alias __activeSequence: p.activeSequence
        property alias __nextActiveSequence: p.nextActiveSequence

        property var __activeFrame
        property int __sequencePathLength: p.sequencePath.length

        property int __randomInt: 0
        property var __mathFloor: Math.floor
        property var __mathRandom: Math.random

        property var __activeSequenceCum
        property string __nextSequence: ""

        property string __seqName: ""
        property int __endSequenceFrameIndex: 0

        onTriggered: {
            // For inital frame
            if(!__activeSequence) {
                __activeSequence = __validSequences[p.activeSequenceIndex]

                if(__activeSequence === undefined) {
                    Qak.error('ItemAnimation','No active sequence can be set. Stopping...')
                    r.setRunning(false)
                    return
                }
            }

            // NOTE stupid trigger if goalSequence is set during init
            if(goalSequence !== "" && __sequencePathLength <= 0) {
//                Qak.debug('ItemAnimation', 'Correcting goalSequence',goalSequence) //¤qakdbg
                setGoalSequence()
            }

            // If instructed to set a new active sequence
            if(__nextActiveSequence != '') {
                //Qak.debug('Next sequence',nSeq,'('+activeSequenceIndex+')','weight',totalWeight,'randInt',randInt)
                setActiveSequence(__nextActiveSequence)

                if(p.signalGoalSequenceReached) {
                    p.signalGoalSequenceReached = false
                    r.goalSequenceReached()
                }

                __nextActiveSequence = ""
            }

            // Figure out next frame
            __activeFrame = __activeSequence.frames[p.sequenceFrameIndex]

            // Show the active frame
            if(r.frame === __activeFrame) // NOTE Hack (again) to work around of variable user assignment
                p.emitFrameSynced()
            else
                r.frame = __activeFrame // this should idealy be emitted as changed even if the same frame?

//                Qak.debug('ItemAnimation','showing',__activeSequence.name,'at frame index',r.frame,'current sequence frame index',p.sequenceFrameIndex) //¤qakdbg

            // TODO optimize
            __endSequenceFrameIndex = __activeSequence.frames.length-1

            if(p.sequenceFrameIndex == __endSequenceFrameIndex) {
//                    Qak.debug('ItemAnimation','end of sequence',__activeSequence.name,'at index',p.sequenceFrameIndex,'- Deciding next sequence...') //¤qakdbg

                __nextSequence = ""
                if(__sequencePathLength > 0) {
                    __nextSequence = p.sequencePath.shift()

                    // TODO fix this mess
                    while(__sequencePathLength > 0 && __nextSequence === __activeSequence.name) {
//                            Qak.debug('ItemAnimation','already at',nextSequence,'trying next') //¤qakdbg
                        __nextSequence = p.sequencePath.shift()
                    }

                    if(__nextSequence === __activeSequence.name)
                        __nextSequence = ""
                    else {
                        __nextActiveSequence = __nextSequence
                        if(__sequencePathLength === 0) {
                            r.goalSequence = ""
                            p.signalGoalSequenceReached = true
                        }
                    }
                } else if('to' in __activeSequence) {
                    __activeSequenceCum = __activeSequence.__toCum

                    __randomInt = __mathFloor(__mathRandom()*__activeSequence.toTotalWeight)

                    for(__seqName in __activeSequenceCum) {

                        if (__randomInt < __activeSequenceCum[__seqName]) {
                            __nextSequence = __seqName
                            break
                        }

                    }

                    // Instruct state to setActiveSequence() next run
                    __nextActiveSequence = __nextSequence

                } else if(__endSequenceFrameIndex == 0) {
                    // The sequence only has one frame
//                        Qak.debug('ItemAnimation','Only one frame and nowhere to go next. Stopping...') //¤qakdbg
                    r.setRunning(false)
                    return
                } else { // missing to: {...} entry - stop
//                        Qak.debug('ItemAnimation','nowhere to go. Stopping...') //¤qakdbg
                    r.setRunning(false)
                    return
                }

            } else
                p.sequenceFrameIndex++

        }

    }

    PropertyToggle {
        id: _frames
        anchors { fill: parent }

        property: "opacity"
        on: 1
        off: 0

        property alias frame: r.frame
        toggle: frame
        property bool balanced: children.length > 0 && p.totalAmountOfFrames === children.length

    }

}
