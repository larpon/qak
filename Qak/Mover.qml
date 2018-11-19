import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0

Item {
    id: mover

    visible: (opacity > 0 && scale !== 0 && width > 0 && height > 0)

    property Item target: parent

    property bool locked: false
    readonly property bool moving: pathAnim.running && !paused

    property bool paused: false

    property point anchorPoint: Qt.point(0,0)

    property real speedModifier: 1 // Deprecated
    property real speed: 1/speedModifier

    property int duration: 0

    property var moveQueue: []

    property bool smoothed: false

    property alias easing: pathAnim.easing

    signal beforeStart
    signal started
    signal stopped

    function moveTo(x,y) {
        if((x === undefined || x === null || y === undefined || y === null) || isNaN(x) || isNaN(y))
            return

        if(Aid.isObject(x) && 'x' in x && 'y' in x) {
            pushMove(x.x,x.y)
        } else
            pushMove(x,y)
        start()
    }

    function pushMove(x,y) {
        if((x === undefined || x === null || y === undefined || y === null) || isNaN(x) || isNaN(y))
            return

        if(Aid.isObject(x) && 'x' in x && 'y' in x) {
            moveQueue.push(x)
        } else
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

    function start() {
        if(locked) {
//            Qak.debug(Qak.gid+'Mover','::startMoving','target is locked') //¤qakdbg
            return
        }

        pathAnim.stop()

        beforeStart()
        var list = []
        var d = 0
        // TODO make an anchor point option
        var pp = Qt.point(target.x+anchorPoint.x,target.y+anchorPoint.y)
        while(moveQueue.length > 0) {
            var p = popMove()
            d += distance(pp,p)
            var temp
            if(smoothed)
                temp = pathCurveComponent.createObject(path, {"x":p.x, "y":p.y})
            else
                temp = pathLineComponent.createObject(path, {"x":p.x, "y":p.y})
            list.push(temp)
            pp = p
        }

//        Qak.debug(Qak.gid+'Mover','::startMoving','Travel distance',d) //¤qakdbg
        if(isNaN(d)) {
            moveQueue = []
            return
        }

        pathAnim.userDuration = d
        if(duration > 0) {
            pathAnim.__duration = duration
        }

        if(list.length > 0) {
            path.pathElements = list
            pathAnim.start()
        }
    }

    function startMoving() {
        Qak.warn(Qak.gid+'Mover','::startMoving','is deprecated. Use start() instead')
        start()
    }

    function stop() {
        pathAnim.stop()
    }

    function distance(p1,p2) {
        return Math.sqrt( (p1.x-p2.x)*(p1.x-p2.x) + (p1.y-p2.y)*(p1.y-p2.y) )
    }

    // FROM https://www.particleincell.com/wp-content/uploads/2012/06/bezier-spline.js
    // FROM https://www.particleincell.com/2012/bezier-splines/
    function computeControlPoints(K) {
        var p1=[],
        p2=[],
        n = K.length-1,

        // rhs vector
        a=[],
        b=[],
        c=[],
        r=[],

        // for-loop index
        i

        // left most segment
        a[0]=0
        b[0]=2
        c[0]=1
        r[0] = K[0]+2*K[1]

        // internal segments
        for (i = 1; i < n - 1; i++) {
            a[i]=1
            b[i]=4
            c[i]=1
            r[i] = 4 * K[i] + 2 * K[i+1]
        }

        // right segment
        a[n-1]=2
        b[n-1]=7
        c[n-1]=0
        r[n-1] = 8*K[n-1]+K[n]

        // solves Ax=b with the Thomas algorithm (from Wikipedia)
        for (i = 1; i < n; i++) {
            m = a[i]/b[i-1]
            b[i] = b[i] - m * c[i - 1]
            r[i] = r[i] - m*r[i-1]
        }

        p1[n-1] = r[n-1]/b[n-1]
        for (i = n - 2; i >= 0; --i) {
            p1[i] = (r[i] - c[i] * p1[i+1]) / b[i]
        }

        // we have p1, now compute p2
        for (i=0;i<n-1;i++) {
            p2[i]=2*K[i+1]-p1[i+1]
        }

        p2[n-1]=0.5*(K[n]+p1[n-1])

        return {p1:p1, p2:p2}
    }

    Component
    {
        id: pathLineComponent
        PathLine
        {

        }
    }

    Component
    {
        id: pathCurveComponent
        PathCurve {

        }
    }

    PathAnimation {
        id: pathAnim

        paused: running && mover.paused

        property real userDuration: 2000
        property real __duration: 0
        duration: __duration > 0 ? __duration : userDuration * 2 * (1/speed)

        target: mover.target
        anchorPoint: mover.anchorPoint

        path: Path {
            id: path
        }

        onStopped: mover.stopped()
        onStarted: mover.started()
    }
}
