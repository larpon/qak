import QtQuick 2.5
import QtQuick.Controls 1.2
import QtQuick.Window 2.2

import "./"

ApplicationWindow {

    id: core

    title: qsTr("QAGE")+" ("+width+"x"+height+")"

    x: 2200
    y: (Screen.desktopAvailableHeight/2)-(height/2)

    width: 800
    height: 600

    readonly property real halfWidth: width/2
    readonly property real halfHeight: height/2

    color: "black"

    visible: true

    // This is where children will go
    default property alias contents: canvas.data

    readonly property real aspectRatio: width/height

    readonly property alias viewport: viewport
    readonly property alias canvas: canvas

    property bool debug: debugBuild

    property string screenmode: "windowed"
    property int fillmode: Image.PreserveAspectFit //Image.PreserveAspectCrop //Image.Stretch

    readonly property int viewportWidthDiff: viewport.scaledWidth - viewport.width

    property real thresholdPercent: 25.0

    readonly property int assetMultiplier: (((Math.floor(((viewportWidthDiff/core.viewport.width)*100) / thresholdPercent) * thresholdPercent)+thresholdPercent)/thresholdPercent)

    // Signals
    signal resized

    //flags: Qt.FramelessWindowHint | Qt.CustomizeWindowHint

    Component.onCompleted: {
        //if(debug) console.debug.apply(console, arguments);
        //console.log.bind(console)
        //canvas.fix()
    }

    Component.onDestruction: {

    }

    onScreenChanged: log("Screen changed")
    onScreenmodeChanged: {
        log("Screenmode",screenmode)
        if(screenmode == "full")
            core.showFullScreen()
        else if(core.screenmode == "windowed")
            core.showNormal()
        else
            core.showNormal()
    }

    // NOTE Keeping for reference calculations
    // This is the very base for calculating the suggested asset size
    /*
    function calculateMapStep() {
        if(!autoMapSource || ignore)
            return

        if(viewport.scaledWidth == 0 || core.targetWidth == 0)
            return

        // How many percent of target width are we off?
        // + = over
        // - = under
        var pct = (viewportWidthDiff/core.viewport.width)*100

        // Step in percent
        var percentStep = 25.0

        // Round to nearest step size
        // ... -50,-25,0,25,50 ...
        var step = Math.floor(pct / percentStep) * percentStep

        // Convert from percent step to integer step
        // ... -3,-2,-1,0,1,2,3 ...
        step = (step+percentStep)/percentStep

        // Round integer to nearest asset step size
        // ... -4,-2,0,2,4 ...
        step = Math.floor(step / assetStep) * assetStep

        mapStep = step
    }
    */

    function init() {

    }

    function toggleScreenmode() {
        if(screenmode === "windowed")
           screenmode = "full"
        else
           screenmode = "windowed"
    }

    function toggleFillmode() {
        if(fillmode === Image.PreserveAspectFit)
           fillmode = Image.PreserveAspectCrop
        else if(fillmode === Image.Stretch)
           fillmode = Image.PreserveAspectFit
        else
           fillmode = Image.Stretch
    }

    /*
    function asset(path) {
        path = 'qrc:///'+path
        return path
    }
    */

    function clamp(a,b,c) {
        return Math.max(b,Math.min(c,a))
    }

    function remap(oldValue, oldMin, oldMax, newMin, newMax) {
        // Linear conversion
        // NewValue = (((OldValue - OldMin) * (NewMax - NewMin)) / (OldMax - OldMin)) + NewMin
        return (((oldValue - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) + newMin;
    }

    function log() {
        //log.history=log.history||[]
        //log.history.push(arguments)
        if(console) {
            // 1. Convert args to a normal array
            var args = Array.prototype.slice.call(arguments);

            // 2. Prepend log prefix log string
            args.unshift("QAGE");

            // 3. Pass along arguments to console.log
            console.log.apply(console, args);
            //console.log('QAGE',Array.prototype.slice.call(arguments))
        }
    }

    function error() {
        //log.history=log.history||[]
        //log.history.push(arguments)
        if(console) {
            var args = Array.prototype.slice.call(arguments)
            args.unshift("QAGE ERROR")
            console.error.apply(console, args)
        }
    }

    function db() {
        //db.history=db.history||[]
        //db.history.push(arguments)
        if(console && debug) {
            var args = Array.prototype.slice.call(arguments)
            args.unshift("QAGE DEBUG")
            console.debug.apply(console, args)
        }
    }

    function warn() {
        //db.history=db.history||[]
        //db.history.push(arguments)
        if(console) {
            var args = Array.prototype.slice.call(arguments)
            args.unshift("QAGE WARNING")
            console.warn.apply(console, args)
        }
    }

    Item {
        id: viewport

        clip: true

        x: 0; y: 0
        width: core.width; height: core.height

        readonly property real halfWidth: width/2
        readonly property real halfHeight: height/2

        readonly property real scaledWidth: width*activeScaler.xScale
        readonly property real scaledHeight: height*activeScaler.yScale

        readonly property real aspectRatio: width/height

        property string fillmodeString: ""
        onFillmodeStringChanged: log('Fillmode',fillmodeString)

        readonly property Scale activeScaler: selectScaler(fillmode)

        transform: activeScaler

        Component.onCompleted: {
            fix()
        }

        Scale {
            id: aspectScale
            xScale: Math.min(core.width/viewport.width,core.height/viewport.height)
            yScale: xScale

        }

        Scale {
            id: aspectScaleCrop
            xScale: Math.max(core.width/viewport.width,core.height/viewport.height)
            yScale: xScale
            origin.x: (viewport.width*xScale)/core.width
            origin.y: (viewport.height*yScale)/core.height
        }

        Scale {
            id: stretchScale
            xScale: width/viewport.width
            yScale: height/viewport.height
        }

        Connections {
            target: core

            onAspectRatioChanged: {
                viewport.fix()
            }

            onFillmodeChanged: {
                viewport.fix()
            }
        }

        function fix() {
            viewport.x = 0
            viewport.y = 0

            if(core.aspectRatio == viewport.aspectRatio) {
                fillmodeString = "no boxes"
                return
            } else if(core.fillmode === Image.Stretch) {
                fillmodeString = "stretch"
                return
            } else if(core.fillmode === Image.PreserveAspectCrop) {
                viewport.x = (core.width-(viewport.width*aspectScaleCrop.xScale))/2
                viewport.y = (core.height-(viewport.height*aspectScaleCrop.yScale))/2
                fillmodeString = "preserve aspect crop"
                return
            }

            var nx = (core.width-(viewport.width*aspectScale.xScale))/2
            var ny = (core.height-(viewport.height*aspectScale.yScale))/2

            if(core.aspectRatio < viewport.aspectRatio) {
                fillmodeString = "preserve aspect fit (horizontal boxes)"
                viewport.y = ny
            }

            if(core.aspectRatio > viewport.aspectRatio) {
                fillmodeString = "preserve aspect fit (vertical boxes)"
                viewport.x = nx
            }
        }

        function selectScaler(fm) {
            return fm === Image.PreserveAspectFit ? aspectScale : fm === Image.PreserveAspectCrop ? aspectScaleCrop : stretchScale
        }

        Rectangle {
            anchors.fill: parent
            color: core.debug ? "grey" : "transparent"
            visible: color != "transparent"
        }

        Item {
            id: canvas

            width: viewport.width
            height: viewport.height

            readonly property real halfWidth: width/2
            readonly property real halfHeight: height/2

        }

    }

    Item {
        anchors.fill: parent
        focus: true
        Keys.onReleased: {
            db("Got key event",event,event.key)

            var key = event.key

            if (key == Qt.Key_Escape || key == Qt.Key_Q)
                Qt.quit()

            if(key == Qt.Key_Back || key == Qt.Key_Backspace) {
                Qt.quit()
            }

            if (key == Qt.Key_F)
                toggleScreenmode()

            if (key == Qt.Key_G)
                toggleFillmode()

            if (key == Qt.Key_D)
                core.debug = !core.debug

            //if(key == Qt.Key_Up)
                //settings.contrast = settings.contrast + 0.01
            //if(key == Qt.Key_Down)
                //settings.contrast = settings.contrast - 0.01
            //if(key == Qt.Key_Left)
                //settings.brightness = settings.brightness - 0.01
            //if(key == Qt.Key_Right)
                //game.nextLevel() //settings.brightness = settings.brightness + 0.01
        }
    }
}
