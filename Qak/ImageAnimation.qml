import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0
import Qak.QtQuick 2.0 as QakQuick

/*
 * TODO add 'sources' property to support multiple animations
 * TODO re-write in C++ - the code is a mess - running states are hard to use and predict
 * Remember to include access to the actual Component showed - see use of 'frames' property
 */
Entity {
    id: imageAnimation

    adaptSource: enabled

    property bool enabled: true

    property bool running: true
    // Stupid hack to expose if the animation is actually running (due to QML property running user vs. system read/write)
    readonly property alias animating: animControl.running

    property int defaultFrameDelay: 60

    property var sequences: []
    readonly property alias sequence: state.activeSequence
    readonly property alias sequenceName: state.currentActiveSequence

    readonly property alias balanced: frameContainer.balanced

    property size sourceSize: Qt.size(width,height)

    property string goalSequence: ""

    property var frames: ({})

    property int currentFrame: 0
    onCurrentFrameChanged: {
        setFrame(currentFrame)
    }

    onGoalSequenceChanged: {
        setGoalSequence()
    }

    function jumpTo(sequenceName) {
        animControl.stop()
        restart()
        setActiveSequence(sequenceName)
        animControl.restart()
        //Qak.debug('ImageAnimation','jumpTo',sequenceName)
    }

    function setGoalSequence() {
        if(!state.activeSequence)
            return

        if(goalSequence === "")
            return

        state.sequencePath = []

        var from = state.activeSequence.name
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
            Qak.error('ImageAnimation','No path from',from,'to',to,'ignoring goalSequence')
            return
        }

        if(route.length > 1 && route[0] === from) {
            //Qak.info('ImageAnimation','already at',from,'removing from path')
            route.shift()
        }

        /* // TODO This is fucking up situations where goalSequence is set during initialization
        if(route.length > 0 && route[0] === goalSequence) {
            Qak.info('ImageAnimation','already at goalSequence',goalSequence)
            goalSequenceReached()
            goalSequence = ""
            return
        }*/

//        Qak.debug(Qak.gid+'ImageAnimation','goalSequence',route.join(' -> ')) //¤qakdbg
        state.sequencePath = route
    }

    signal goalSequenceReached

    signal frame(int frame, string sequenceName)

    signal restarted

    onSequencesChanged: {
//        Qak.debug(Qak.gid+'ImageAnimation','reading sequences') //¤qakdbg
        animControl.canRun = false
        state.sequenceNameIndex = {}
        for(var i in sequences) {
            var s = sequences[i]
            // TODO validate each sequence object - or force use of some new QML type e.g. "SequenceItem" ??
            state.sequenceNameIndex[s.name] = i

            if('reverse' in s && s.reverse && ('frames' in s && Object.prototype.toString.call( s.frames ) === '[object Array]')) {
//                Qak.debug(Qak.gid+'ImageAnimation','reversing',s.name) //¤qakdbg
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

        property string currentActiveSequence: ""
        property string nextActiveSequence: ""
        property var sequencePath: ([])

        property bool signalGoalSequenceReached: false

        property var sequenceNameIndex: ({})

        property int totalAmountOfFrames: 0

        function reset() {
//            Qak.debug(Qak.gid+'ImageAnimation','state reset') //¤qakdbg
            currentFrameIndex = 1
            currentSequenceFrameIndex = 0
            currentFrameDelay = defaultFrameDelay
            activeSequenceIndex = 0
            activeSequence = undefined
            currentActiveSequence = ""
            nextActiveSequence = ""
            sequencePath = []
            signalGoalSequenceReached = false
            sequenceNameIndex = {}
            totalAmountOfFrames = frameContainer.children.length
        }
    }

    function restart() {
        reset()

        //state.totalAmountOfFrames = frameContainer.children.length

        running = true

        var tmpSequneces = sequences
        sequences = tmpSequneces
        restarted()
    }

    function reset() {
//        Qak.debug(Qak.gid+'ImageAnimation','reset') //¤qakdbg

        state.reset()

        goalSequence = ""
        animControl.canRun = false

    }

    function stop() {
        animControl.stop()
    }

    function start() {
        animControl.start()
    }

    function setActiveSequence(name) {
        animControl.stop()

        if(!(name in state.sequenceNameIndex)) {
            Qak.error('Can\'t find sequence named',name)
            return
        }

        state.activeSequenceIndex = state.sequenceNameIndex[name]
        state.activeSequence = sequences[state.activeSequenceIndex]
        if('name' in state.activeSequence) {
            state.currentActiveSequence = state.activeSequence.name
        }
        state.currentSequenceFrameIndex = 0
        if('frames' in state.activeSequence && Aid.isArray( state.activeSequence.frames )) {
            //state.currentFrameIndex = state.activeSequence.frames[state.currentSequenceFrameIndex]
            currentFrame = state.activeSequence.frames[state.currentSequenceFrameIndex]
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

    property alias __currentFrameIndex: state.currentFrameIndex
    property alias __currentActiveSequence: state.currentActiveSequence
    property alias __activeSequence: state.activeSequence
    function setFrame(index) {
        __currentFrameIndex = index
        if(!__activeSequence)
            frame(__currentFrameIndex, '')
        else
            frame(__currentFrameIndex, __currentActiveSequence)
    }

    Timer {
        id: animControl
        interval: state.currentFrameDelay
//        onIntervalChanged: Qak.debug(Qak.gid+'ImageAnimation','animControl','interval',interval) //¤qakdbg
        repeat: true
        running: !paused && canRun && frameContainer.balanced
        //triggeredOnStart: true

        property bool canRun: false
        property bool paused: imageAnimation.paused || !imageAnimation.running

        property alias __activeSequence: state.activeSequence
        property alias __nextActiveSequence: state.nextActiveSequence
        property int __endSequenceFrameIndex: 0
        property string __nextSequence
        onTriggered: { // TODO optimize!

            // For inital frame
            if(!__activeSequence) {
                __activeSequence = sequences[state.activeSequenceIndex]

                if(__activeSequence === undefined) {
                    Qak.error('No active sequence can be set. Stopping...')
                    imageAnimation.running = false
                    animControl.stop()
                    return
                }
            }

            // NOTE stupid trigger if goalSequence is set during init
            if(goalSequence !== "" && state.sequencePath.length <= 0) {
//                Qak.debug(Qak.gid+'ImageAnimation', 'Correcting goalSequence',goalSequence) //¤qakdbg
                setGoalSequence()
            }

            // If instructed to set a new active sequence
            if(__nextActiveSequence != '') {
                setActiveSequence(__nextActiveSequence)

                if(state.signalGoalSequenceReached) {
                    state.signalGoalSequenceReached = false
                    imageAnimation.goalSequenceReached()
                }

                __nextActiveSequence = ""
            }

            // Figure out next frame
            if('frames' in __activeSequence && Aid.isArray( __activeSequence.frames )) {

                var activeFrame = __activeSequence.frames[state.currentSequenceFrameIndex]
                // Show the active frame
                if(currentFrame === activeFrame) // NOTE Hack (again) to work around of variable user assignment
                    setFrame(activeFrame)
                else
                    currentFrame = activeFrame // this should idealy be emitted as changed even if the same frame?
                //setFrame(state.activeSequence.frames[state.currentSequenceFrameIndex])
                //state.currentFrameIndex =
                //frame(state.currentFrameIndex, state.activeSequence.name)
//                Qak.debug(Qak.gid+'ImageAnimation','showing',state.activeSequence.name,'at frame index',state.currentFrameIndex,'current sequence frame index',state.currentSequenceFrameIndex) //¤qakdbg


                // TODO optimize
                __endSequenceFrameIndex = __activeSequence.frames.length-1

                if(state.currentSequenceFrameIndex == __endSequenceFrameIndex) {
//                    Qak.debug(Qak.gid+'ImageAnimation','end of sequence',state.activeSequence.name,'at index',state.currentSequenceFrameIndex,'- Deciding next sequence...') //¤qakdbg

                    __nextSequence = ""
                    if(state.sequencePath.length > 0) {
                        __nextSequence = state.sequencePath.shift()

                        // TODO fix this mess
                        while(state.sequencePath.length > 0 && __nextSequence === state.activeSequence.name) {
//                            Qak.debug(Qak.gid+'ImageAnimation','already at',nextSequence,'trying next') //¤qakdbg
                            __nextSequence = state.sequencePath.shift()
                        }

                        if(__nextSequence === __activeSequence.name)
                            __nextSequence = ""
                        else {
                            __nextActiveSequence = __nextSequence
                            if(state.sequencePath.length === 0) {
                                imageAnimation.goalSequence = ""
                                state.signalGoalSequenceReached = true
                            }
                        }
                    } else if('to' in __activeSequence) {
                        var seqTo = __activeSequence.to

                        var totalWeight = 0, cumWeight = 0
                        for(var seqName in seqTo) {
                            totalWeight += seqTo[seqName]
                        }
                        var randInt = Math.floor(Math.random()*totalWeight)

                        for(seqName in seqTo) {
                            if(seqTo[seqName] <= 0)
                                continue

                            cumWeight += seqTo[seqName]
                            if (randInt < cumWeight) {
                                __nextSequence = seqName
                                break
                            }

                        }

                        // Handle a to: entry with all 0 weights
                        if(__nextSequence === "") {
//                            Qak.debug(Qak.gid+'ImageAnimation','No next sequence due to 0 weight(s). Stopping...') //¤qakdbg
                            imageAnimation.running = false
                            animControl.stop()
                            return
                        }

                        // Instruct state to setActiveSequence() next run
                        __nextActiveSequence = __nextSequence

                    } else if(__endSequenceFrameIndex == 0) {
                        // The sequence only has one frame
//                        Qak.debug(Qak.gid+'ImageAnimation','Only one frame and nowhere to go next. Stopping...') //¤qakdbg
                        imageAnimation.running = false
                        animControl.stop()
                        return
                    } else { // missing to: {...} entry - stop
//                        Qak.debug(Qak.gid+'ImageAnimation','nowhere to go. Stopping...') //¤qakdbg
                        imageAnimation.running = false
                        animControl.stop()
                        return
                    }

//                    Qak.debug(Qak.gid+'ImageAnimation','next sequence',__nextActiveSequence) //¤qakdbg
                } else
                    state.currentSequenceFrameIndex++

            } else {
                Qak.error(Qak.gid+'ImageAnimation','No frames. Skipping...')
                imageAnimation.running = false
                animControl.stop()
                return
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

        // Match any '<digit>.' entries or '.<digit>.'
        // TODO make more fail safe as any preceeding '<digit>.' in adaptiveSource string will be replaced
        // Maybe only make replacement on adaptiveSource basename() or something
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

            // TODO FIXME proper matching
            var startWithDot = (match.charAt(0) === '.') ? "." : ""

            // TODO fix this (async = true (which is default) doesn't work in HammerBees?)
            // Incubate.asynchronous = false
            while(Qak.resource.exists(nextSource)) {
                Incubate.later(imageComponent, frameContainer, {'frame':frame,'source':nextSource,'state':state}
//                    ,function(o){Qak.debug(Qak.gid+'ImageAnimation','Incubated',o.source)} //¤qakdbg
                )
                frame++
                digit++

                var next = pad((digit),padding)
                nextSource = adaptiveSource.replace(match, startWithDot+next+".") // TODO improve this some day - see NOTE at 'match' start

            }
            try {
                Incubate.incubate()
            } catch(e) {
                console.error('Exception on incubating image component',e)
            }

            var lastFrameSource = adaptiveSource.replace(match, startWithDot+pad(frame,padding)+".") // TODO improve this some day - see NOTE at 'match' start

            state.totalAmountOfFrames = frame-1

            //Qak.debug('ImageAnimation','Assuming animation source based on match','"'+match+'"','number','"'+number+'"','has',frame,'frames','first frame',adaptiveSource,'last frame',lastFrameSource,'file name has padding',padding)

        } else {
            Qak.warn(Qak.gid+'ImageAnimation','Assuming single image source')
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
                //Qak.log(Qak.gid+'ImageAnimation','Component Image',state,'frame',frame,'source',source)
                imageAnimation.frames[image.frame+""] = image
            }

            width: parent.width
            height: parent.height
            //source: adaptiveSource.replace(state.replacer, pad(frame,state.fileStringPadding))
            sourceSize: imageAnimation.sourceSize

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
        anchors { fill: parent }
        id: frameContainer
        property bool balanced: children.length > 0 && state.totalAmountOfFrames === children.length
    }



}
