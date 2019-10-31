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

    readonly property real halfWidth: width*0.5
    readonly property real halfHeight: height*0.5

    default property alias content: _frames.data
    property alias it: r

    //property bool enabled: true
    property bool paused: false

    property bool loadFrames: true

    running: true
//    onRunningChanged: Qak.debug(Qak.gid+'ItemAnimation','.running',running) //¤qakdbg

//    onVisibleChanged: Qak.debug(Qak.gid+'ItemAnimation','.visible',visible) //¤qakdbg

    property alias property: _frames.property
    property alias on: _frames.on
    property alias off: _frames.off

    property int defaultFrameDelay: 60
    readonly property alias frameDelay: p.frameDelay

    property var sequences: []
    property var __validSequences: []
    readonly property alias sequence: p.activeSequence
    readonly property alias sequenceName: p.currentActiveSequence

    readonly property bool __itemAnimationStable: loadFrames ? balanced && count == model : true
    readonly property bool stable: __itemAnimationStable
    readonly property alias balanced: _frames.balanced
    onStableChanged: {
        p.spawningFrames = false
        setFrame(frame+1); setFrame(frame-1)

        // NOTE set initial active sequence
        if(!__activeSequence) {
            __activeSequence = __validSequences[p.activeSequenceIndex]
            if(__activeSequence === undefined) {
                Qak.error(Qak.gid+'ItemAnimation','onStableChanged','No active sequence can be set.')
            }
        }
        setGoalSequence()
    }


    property Component delegate
    property int model: 0
    onModelChanged: {
        if(model <= 0 || !delegate || !loadFrames)
            return
        p.spawnFrames()
    }

    onDelegateChanged: {
        if(model <= 0 || !delegate || !loadFrames)
            return
        p.spawnFrames()
    }

    onLoadFramesChanged: {
//        Qak.debug(Qak.gid+'ItemAnimation','.loadFrames',loadFrames) //¤qakdbg
        if(model <= 0 || !delegate || !loadFrames)
            return
        if(loadFrames)
            p.spawnFrames()
        else
            p.clearFrames()
    }

    Component.onDestruction: p.clearFrames()

    property bool continueFromGoalSequence: false

    property var frames: ({})
    readonly property alias count: p.totalAmountOfFramesSpawned

    //property int frame: 1
    onFrameChanged: p.emitFrameSynced()

    onGoalSequenceChanged: {
//        Qak.debug(Qak.gid+'ItemAnimation','.goalSequence',goalSequence) //¤qakdbg
        setGoalSequence()
    }

    function jumpTo(sequenceName) {
//        Qak.debug(Qak.gid+'ItemAnimation','::jumpTo',sequenceName) //¤qakdbg
        frameTicker.ready = false
        restart()
        setActiveSequence(sequenceName)
        frameTicker.ready = true
    }

    function setGoalSequence() {

        if(!p.activeSequence) {
//            Qak.debug(Qak.gid+'ItemAnimation','setGoalSequence','no current activeSequence') //¤qakdbg
            return
        }

        if(goalSequence === "") {
//            Qak.debug(Qak.gid+'ItemAnimation','setGoalSequence','goalSequence is blank') //¤qakdbg
            return
        }

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
//            Qak.debug(Qak.gid+'ItemAnimation','goalSequence','already at',from,'removing from path') //¤qakdbg
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

//        Qak.debug(Qak.gid+'ItemAnimation','goalSequence',route.join(' -> ')) //¤qakdbg
        p.sequencePath = route
        if(!r.running)
            r.setRunning(true)
    }

    signal goalSequenceReached
//    onGoalSequenceReached: Qak.debug(Qak.gid+'ItemAnimation','goalSequenceReached',goalSequence) //¤qakdbg

    signal frameSynced(int frame, string sequenceName)

    signal restarted

    onSequencesChanged: {
//        Qak.debug(Qak.gid+'ItemAnimation','reading sequences') //¤qakdbg
        __validSequences = []
        frameTicker.ready = false
        p.sequenceNameIndex = {}
        for(var i in sequences) {
            var s = Aid.clone(sequences[i])

            // Validate sequence object
            if(!('frames' in s) || !Aid.isArray( s.frames ))
                continue

            // TODO validate each sequence object - or force use of some new QML type e.g. "SequenceItem" ??
            p.sequenceNameIndex[s.name] = i

            if('reverse' in s && s.reverse && ('frames' in s && Object.prototype.toString.call( s.frames ) === '[object Array]')) {
//                Qak.debug(Qak.gid+'ItemAnimation','reversing',s.name) //¤qakdbg
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

    Item {
        id: junk
        visible: false
    }

    QakObject {
        id: p

        property int sequenceFrameIndex: 0
        property int frameDelay: defaultFrameDelay

        property int activeSequenceIndex: 0
        property var activeSequence

        property string currentActiveSequence: ""
        property string nextActiveSequence: ""
        property var sequencePath: ([])
        function touchSequencePath() { var t = sequencePath; sequencePath = t}

        property bool signalGoalSequenceReached: false

        property var sequenceNameIndex: ({})

        property int totalAmountOfFrames: _frames.children.length
        property int totalAmountOfFramesSpawned: 0

        property bool spawningFrames: false
        property bool clearingFrames: false

        function clearFrames(now) {
            now = now
            var i, f
            clearingFrames = true
            for(i in frames) {
                totalAmountOfFramesSpawned--
                f = frames[i]
                if(Boolean(now)) {
                    if('destroy' in f && Aid.isFunction(f.destroy))
                        f.destroy()
                } else {
                    f.parent = junk
                    if('deleteLater' in f && Aid.isFunction(f.deleteLater))
                        f.deleteLater()
                }
            }
            frames = {}
            _frames.clear()
            clearingFrames = false
        }

        function spawnFrames() {
            if(!loadFrames) {
                Qak.warn(Qak.gid+'ItemAnimation','loadFrames is false')
                return
            }
            if(spawningFrames) {
                Qak.warn(Qak.gid+'ItemAnimation','already spawning frames')
                return
            }
            if(clearingFrames) {
                Qak.warn(Qak.gid+'ItemAnimation','already clearing frames')
                return
            }
            spawningFrames = true
//            Qak.debug(Qak.gid+'ItemAnimation','spawning frames') //¤qakdbg
            clearFrames()

            for(var i = 1; i <= model; i++) {
                Incubate.later(delegate, _frames, { frame: i }, function(o){
                    r.frames[o.frame+""] = o
                    totalAmountOfFramesSpawned++
                } )
            }
            try {
                Incubate.incubate()
            } catch(e) {
                Qak.error('Exception on incubating frames',e)
            }
        }

        function emitFrameSynced() {
            //if(!activeSequence)
            //    frameSynced(r.frame, '')
            //else
                frameSynced(r.frame, currentActiveSequence)
        }

        function reset() {
//            Qak.debug(Qak.gid+'ItemAnimation','p::reset') //¤qakdbg
            sequenceFrameIndex = 0
            p.frameDelay = defaultFrameDelay
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
//        Qak.debug(Qak.gid+'ItemAnimation','::restart') //¤qakdbg
        reset()

        setRunning(true)

        // TODO fix this some day - should be needed after a reset? Or maybe restart shouldn't call reset at all
        var tmpSequences = sequences
        sequences = tmpSequences
        restarted()
    }

    function reset() {
//        Qak.debug(Qak.gid+'ItemAnimation','::reset') //¤qakdbg
        p.reset()

        setGoalSequence("")
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
        frameTicker.ready = false

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

        r.setFrame(__activeSequence.frames[p.sequenceFrameIndex])

        // Figure out frame delay
        if('duration' in __activeSequence) {
            // NOTE TODO TIMER? once the animation is started parameters can't be changed on it
            // So if anything changes the animation must be restarted
            if(p.frameDelay !== __activeSequence.duration)
                p.frameDelay = __activeSequence.duration
        } else if('delay' in __activeSequence) {
            // NOTE TODO TIMER? once the animation is started parameters can't be changed on it
            // So if anything changes the animation must be restarted
            if(p.frameDelay !== __activeSequence.delay)
                p.frameDelay = __activeSequence.delay
        } else {
            if(p.frameDelay != defaultFrameDelay)
                p.frameDelay = defaultFrameDelay
        }

//        Qak.debug(Qak.gid+'ItemAnimation','active sequence is now',__activeSequence.name,'at frame',__activeSequence.frames[p.sequenceFrameIndex],'index',p.sequenceFrameIndex) //¤qakdbg
        frameTicker.ready = true
    }

    Timer {
        id: frameTicker
        interval: p.frameDelay

        repeat: true
        running: r.running && !frameTicker.paused && ready && r.stable
//        onRunningChanged: Qak.debug(Qak.gid+'ItemAnimation','frameTicker.running',running) //¤qakdbg

        triggeredOnStart: true

        property bool ready: false
//        onReadyChanged: Qak.debug(Qak.gid+'ItemAnimation','frameTicker.ready',ready) //¤qakdbg
        property bool paused: r.paused
//        onPausedChanged: Qak.debug(Qak.gid+'ItemAnimation','frameTicker.paused',paused) //¤qakdbg

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
            tick()
        }

        function decideByTo() {
            if('to' in __activeSequence) {
                __activeSequenceCum = __activeSequence.__toCum
                __randomInt = __mathFloor(__mathRandom()*__activeSequence.toTotalWeight)

                for(__seqName in __activeSequenceCum) {
                    if (__randomInt < __activeSequenceCum[__seqName]) {
                        __nextSequence = __seqName
                        break
                    }
                }

                if(__nextSequence === "") {
//                    Qak.debug(Qak.gid+'ItemAnimation','::decideByTo',"to is present but no sequences where valid") //¤qakdbg
                    return false
                }

                // Instruct state to setActiveSequence() next run
                __nextActiveSequence = __nextSequence

//                Qak.debug(Qak.gid+'ItemAnimation','::decideByTo','next active sequence',__nextActiveSequence) //¤qakdbg
                return true
            }
//            Qak.debug(Qak.gid+'ItemAnimation','::decideByTo',"couldn't decide next sequence") //¤qakdbg
            return false
        }

        function tick() {

            // For inital frame
            // TODO check if the same code is doing it's job in onStableChanged
//            if(!__activeSequence) {
//                __activeSequence = __validSequences[p.activeSequenceIndex]

//                if(__activeSequence === undefined) {
//                    Qak.error(Qak.gid+'ItemAnimation','::tick','No active sequence can be set. Stopping...')
//                    r.setRunning(false)
//                    return
//                }
//            }

            // TODO NOTE stupid trigger if goalSequence is set during init
            //if(goalSequence !== "" && __sequencePathLength <= 0) {
//            //    Qak.debug(Qak.gid+'ItemAnimation','::tick', 'Correcting goalSequence',goalSequence) //¤qakdbg
            //    setGoalSequence()
            //}

            // If instructed to set a new active sequence
            if(__nextActiveSequence != '') {
//                Qak.debug(Qak.gid+'ItemAnimation','::tick','next active sequence',__nextActiveSequence) //¤qakdbg
                setActiveSequence(__nextActiveSequence)

                if(p.signalGoalSequenceReached) {
                    p.signalGoalSequenceReached = false
                    r.goalSequenceReached()
                }

                __nextActiveSequence = ""
            }

            try {
                __activeFrame = __activeSequence.frames[p.sequenceFrameIndex]
            } catch(e) {
                Qak.error(Qak.gid+'ItemAnimation','::tick','setting active frame failed',p.sequenceFrameIndex)
                //return
            }

            // Show the active frame
            if(r.frame === __activeFrame) // NOTE Hack (again) to work around of variable user assignment
                p.emitFrameSynced()
            else
                r.setFrame(__activeFrame) // this should idealy be emitted as changed even if the same frame?

//                Qak.debug(Qak.gid+'ItemAnimation','::tick','showing',__activeSequence.name,'at frame index',r.frame,'current sequence frame index',p.sequenceFrameIndex) //¤qakdbg

            // Figure out next frame
            // TODO optimize
            __endSequenceFrameIndex = __activeSequence.frames.length-1

            if(p.sequenceFrameIndex == __endSequenceFrameIndex) {
//                Qak.debug(Qak.gid+'ItemAnimation','::tick','end of sequence',__activeSequence.name,'at index',p.sequenceFrameIndex,'- Deciding next sequence...') //¤qakdbg

                __nextSequence = ""
                if(__sequencePathLength > 0) {
                    __nextSequence = p.sequencePath.shift()
                    p.touchSequencePath()

//                    Qak.debug(Qak.gid+'ItemAnimation','::tick','deciding from goalSequence',__nextSequence) //¤qakdbg

                    // TODO fix this mess
                    while(p.sequencePath.length > 0 && __nextSequence === __activeSequence.name) {
//                        Qak.debug(Qak.gid+'ItemAnimation','::tick','already at',__nextSequence,'trying next') //¤qakdbg
                        __nextSequence = p.sequencePath.shift()
                        p.touchSequencePath()
                    }

                    if(__nextSequence === __activeSequence.name)
                        __nextSequence = ""
                    else {
                        __nextActiveSequence = __nextSequence
                        if(__sequencePathLength === 0) {
                            r.setGoalSequence("")
                            p.signalGoalSequenceReached = true
                            if(continueFromGoalSequence) {
//                                Qak.debug(Qak.gid+'ItemAnimation','::tick','continuing from goalSequence') //¤qakdbg
                                decideByTo()
                            }
                        }
                    }
                } else if('to' in __activeSequence) {
                    if(!decideByTo()) {
//                        Qak.debug(Qak.gid+'ItemAnimation','::tick',"couldn't decide by 'to'. Stopping...") //¤qakdbg
                        r.setRunning(false)
                    }
                } else if(__endSequenceFrameIndex == 0) {
                    // The sequence only has one frame
//                    Qak.debug(Qak.gid+'ItemAnimation','::tick','Only one frame and nowhere to go next. Stopping...') //¤qakdbg
                    r.setRunning(false)
                    return
                } else { // missing to: {...} entry - stop
//                    Qak.debug(Qak.gid+'ItemAnimation','::tick','nowhere to go. Stopping...') //¤qakdbg
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

        //enabled: !p.clearingFrames && !p.spawningFrames
        property: "opacity"
        on: 1
        off: 0

        property alias frame: r.frame
        toggle: _frames.frame
        property bool balanced: children.length > 0 && p.totalAmountOfFrames === children.length
    }

    // TODO weird BUG
    // Impossible too add an "overlay" visible Item after the PropertyToggle
    // MouseAreas seem to catch events - but visible entries are only visible if you add them in this element ("r")
    // If you alias a property, say 'front', and somewhere make that your parent the item is hidden - but mouse events sometimes go through?
    // property alias front: r
    // A workaround would be to place your item as a sibling and give it this id reference as a parent

}
