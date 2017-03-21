import QtQuick 2.0

import Qak 1.0

Item {
    id: mover
    property Item target: parent

    property bool locked: false
    readonly property bool moving: pathAnim.running && !paused

    property bool paused: false

    property point anchorPoint: Qt.point(0,0)

    property double speedModifier: 1
    property int duration: 0

    property var moveQueue: []

    signal started
    signal stopped

    function moveTo(x,y) {
        if((x === undefined || x === null || y === undefined || y === null) || isNaN(x) || isNaN(y))
            return
        pushMove(x,y)
        startMoving()
    }

    function pushMove(x,y) {
        if((x === undefined || x === null || y === undefined || y === null) || isNaN(x) || isNaN(y))
            return
        moveQueue.push(Qt.point(x,y))
        /* Use this for binding to moveQueue changes
        var t = moveQueue
        t.push(Qt.point(x,y))
        moveQueue = t
        */
    }

    function popMove() {
        return moveQueue.shift()
        /* Use this for binding to moveQueue changes
        var t = moveQueue
        var o = t.shift()
        moveQueue = t
        return o
        */
    }

    function startMoving() {
        if(locked) {
//        Qak.debug(Qak.gid+'Mover','::startMoving target is locked') //¤qakdbg
            return
        }

        pathAnim.stop()

        var list = []
        var d = 0
        // TODO make an anchor point option
        var pp = Qt.point(target.x+anchorPoint.x,target.y+anchorPoint.y)
        while(moveQueue.length > 0) {
            var p = popMove()
            d += distance(pp,p)
            var temp = component.createObject(path, {"x":p.x, "y":p.y})
            list.push(temp)
            pp = p
        }

//        Qak.debug('Travel distance',d) //¤qakdbg
        if(isNaN(d)) {
            moveQueue = []
            return
        }

        pathAnim.duration = d*2*speedModifier
        if(duration > 0) {
            pathAnim.duration = duration
        }

        if(list.length > 0) {
            path.pathElements = list
            pathAnim.start()
        }
    }

    function stop() {
        pathAnim.stop()
    }

    function distance(p1,p2) {
        return Math.sqrt( (p1.x-p2.x)*(p1.x-p2.x) + (p1.y-p2.y)*(p1.y-p2.y) )
    }

    Component
    {
        id: component
        PathLine
        {

        }
    }

    PathAnimation {
        id: pathAnim

        paused: running && mover.paused

        duration: 2000

        target: mover.target
        anchorPoint: mover.anchorPoint

        path: Path {
            id: path
        }

        onStopped: mover.stopped()
        onStarted: mover.started()
    }
}
