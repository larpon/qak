import QtQuick 2.5

import Qak 1.0
import Qak.QtQuick 1.0

Item {

    id: entity

    default property alias contents: container.data

    property bool locked: false
    property bool draggable: false
    property bool rotatable: false

    property bool adaptSource: true
    property string adaptiveSource: ""
    property alias source: adaptive.source

    AdaptiveSource {
        id: adaptive
        enabled: adaptSource
        target: entity
        targetSourceProperty: "adaptiveSource"
    }

    Item {
        id: container
        anchors.fill: parent

    }

    // Drag'n'Drop functionality
    property bool dragReturnOnReject: true
    property alias dragArea: drag

    property int dragDisplaceX: 0 //main.grow()
    property int dragDisplaceY: 0 //main.grow()

    signal dragAccepted (variant mouse)
    signal dragRejected (variant mouse)
    signal dragStarted (variant mouse)
    signal dragged (variant mouse, variant map)
    signal dragReturn
    signal dragEnded (variant mouse)
    signal dragReturned

    function goBack() {
        dragMoveBackAnimation.running = true
    }

    MouseArea {
        id: drag

        property int ox: draggable ? entity.x : 0
        property int oy: draggable ? entity.y : 0

        enabled: parent.draggable && !parent.locked
        //visible: enabled

        anchors.fill: entity
        anchors.margins: 0 //main.grow()

        drag.target: entity

        onPressed: {
            // NOTE Panic click safety
            if(!dragMoveBackAnimation.running) {
                ox = entity.x
                oy = entity.y
            }

            var map = mapToItem(entity.parent,mouse.x,mouse.y)
            entity.x = map.x-(entity.width/2)+entity.dragDisplaceX
            entity.y = map.y-(entity.height/2)+entity.dragDisplaceY
            Qak.db('drag started',entity)
            dragStarted(mouse)
        }

        onReleased: {
            if(entity.Drag.drop() !== Qt.IgnoreAction) {
                Qak.db('drag accepted',entity)
                dragAccepted(mouse)
            } else {
                Qak.db('drag rejected',entity)
                dragRejected(mouse)
                goBack()
            }
            Qak.db('drag ended',entity)
            dragEnded(mouse)
        }

        onPositionChanged: {
            var map = entity.mapToItem(entity.parent,mouse.x,mouse.y)
            dragged(mouse,map)
        }

        function goBack() {
            if(dragReturnOnReject) {
                dragMoveBackAnimation.running = true
                Qak.db('drag return',entity)
                dragReturn()
            }
        }

        SequentialAnimation {
            id: dragMoveBackAnimation
            ParallelAnimation {
                PropertyAnimation { target: entity; property: "x"; to: drag.ox; easing.type: Easing.InOutQuad }
                PropertyAnimation { target: entity; property: "y"; to: drag.oy; easing.type: Easing.InOutQuad }
            }
            ScriptAction { script: {
                Qak.db('drag returned',entity)
                entity.dragReturned()
            }}
        }
    }

    Drag.active: drag.drag.active
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2

    // Mouse rotate functionality
    MouseRotator {
        id: rotator
        enabled: parent.rotatable && !parent.locked

        anchors.fill: parent
    }

    // Movement
    property var moveQueue: []

    function moveTo(x,y) {
        pushMove(x,y)
        startMoving()
    }

    function pushMove(x,y) {
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
        if(locked)
            return

        pathAnim.stop()

        var list = []
        var d = 0
        // TODO make an anchor point option
        var pp = Qt.point(entity.x+entity.halfWidth,entity.y+entity.halfHeight)
        while(moveQueue.length > 0) {
            var p = popMove()
            d += distance(pp,p)
            var temp = component.createObject(path, {"x":p.x, "y":p.y})
            list.push(temp)
            pp = p
        }
        Qak.db('Travel distance',d)
        pathAnim.duration = d*2
        if(list.length > 0) {
            path.pathElements = list
            pathAnim.start()
        }
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

        duration: 2000

        target: entity

        anchorPoint: Qt.point(entity.halfWidth, entity.halfHeight)
        path: Path {
            id: path
        }
    }
}
