/*!
    \qmltype Entity

    \since 1.0
    \brief The Entity elements provide a way to build
    advanced transformations on Items.

    The Transform element is a base type which cannot be
    instantiated directly. The concrete Transform types are:

    \list
      \li \l Rotation
      \li \l Scale
      \li \l Translate
    \endlist

    The Transform elements let you create and control advanced
    transformations that can be configured independently using
    specialized properties.

    You can assign any number of Transform elements to an \l
    Item. Each Transform is applied in order, one at a time.
*/
import QtQuick 2.0

import Qak 1.0
import Qak.QtQuick 2.0

Item {

    id: entity

    default property alias contents: container.data

    property bool clickable: false
    property bool locked: false
    property bool draggable: false
    property bool rotatable: false

    property bool adaptSource: true
    property string adaptiveSource: ""
    property alias source: adaptive.source

    property Viewport viewport: findViewport(entity)

    readonly property MouseArea input: activeInput()

    function activeInput() {
        if(drag.enabled)
            return drag
        else if(rotator.enabled)
            return rotator
        else
            return standard
    }

    signal clicked(var mouse)
    signal pressed(var mouse)
    signal released(var mouse)
    signal positionChanged(var mouse)

    function findViewport(item) {
        if(item && 'qakViewport' in item && item.qakViewport)
            return item
        else if(item && item.parent)
            return findViewport(item.parent)
        else
            return null
    }

    AdaptiveSource {
        id: adaptive
        enabled: adaptSource
        target: entity
        targetSourceProperty: "adaptiveSource"
        assetMultiplierSource: (viewport && 'assetMultiplier' in viewport) ? viewport : null
    }

    MouseArea {
        id: standard
        anchors { fill: parent }
        enabled: parent.clickable && !parent.draggable && !parent.rotatable
        onClicked: entity.clicked(mouse)
        onPressed: entity.pressed(mouse)
        onReleased: entity.released(mouse)
        onPositionChanged: entity.positionChanged(mouse)
    }

    // Drag'n'Drop functionality

    property alias dragger: drag
    property bool dragReturnOnReject: true
    readonly property bool dragging: drag.dragging
    property alias dragReturnAnimation: dragMoveBackAnimation

    property int dragDisplaceX: 0 //main.grow()
    property int dragDisplaceY: 0 //main.grow()

    signal dragAccepted (variant mouse)
    signal dragRejected (variant mouse)
    signal dragStarted (variant mouse)
    signal dragged (variant mouse, variant map)
    signal dragReturn
    signal dragEnded (variant mouse)
    signal dragReturned

    Drag.active: drag.dragging
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2

    function goBack() {
        dragMoveBackAnimation.running = true
    }

    MouseArea {
        id: drag

        property int ox: draggable ? entity.x : 0
        property int oy: draggable ? entity.y : 0

        enabled: parent.draggable && !parent.locked
        //visible: enabled

        // Distance travelled before the drag is activated
        property int activateDistance: 8
        property real dragDistance: drag.drag.active ? Math.sqrt( (ox-entity.x)*(ox-entity.x) + (oy-entity.y)*(oy-entity.y) ) : 0

        property bool dragging: false
        property bool returning: false

        property bool startDrag: false

        anchors { fill: parent }
        anchors.margins: 0 //main.grow()

        drag.target: entity

        onPressed: {
            entity.pressed(mouse)
            // NOTE Panic click safety
            if(!dragMoveBackAnimation.running) {
                ox = entity.x
                oy = entity.y
            }

            startDrag = true
        }

        onReleased: {
            entity.released(mouse)

            if(dragging) {
                if(entity.Drag.drop() !== Qt.IgnoreAction) {
//                    Qak.debug('drag accepted',entity) //¤qakdbg
                    dragAccepted(mouse)
                } else {
//                    Qak.debug('drag rejected',entity) //¤qakdbg
                    dragRejected(mouse)
                    goBack()
                }
//                Qak.debug('drag ended',entity) //¤qakdbg
                dragEnded(mouse)
                dragging = false
            }
        }

        onPositionChanged: {
            entity.positionChanged(mouse)

            var map = mapToItem(entity.parent,mouse.x,mouse.y)

            if(startDrag && dragDistance > activateDistance) {
                entity.x = map.x-(entity.width/2)+entity.dragDisplaceX
                entity.y = map.y-(entity.height/2)+entity.dragDisplaceY
//                Qak.debug('drag started',entity) //¤qakdbg
                dragging = true
                startDrag = false

                dragStarted(mouse)
            }

            dragged(mouse,map)
        }

        onClicked: if(clickable) entity.clicked(mouse)

        function goBack() {
            if(dragReturnOnReject) {
                dragMoveBackAnimation.running = true
//                Qak.debug('drag return',entity) //¤qakdbg
                dragReturn()
                returning = true
            }
        }

        SequentialAnimation {
            id: dragMoveBackAnimation
            ParallelAnimation {
                PropertyAnimation { target: entity; property: "x"; to: drag.ox; easing.type: Easing.InOutQuad }
                PropertyAnimation { target: entity; property: "y"; to: drag.oy; easing.type: Easing.InOutQuad }
            }
            ScriptAction { script: {
//                Qak.debug('drag returned',entity) //¤qakdbg
                drag.returning = false
                entity.dragReturned()
            }}
        }
    }

    // Mouse rotate functionality
    property alias rotator: rotator
    MouseRotator {
        id: rotator

        anchors { fill: parent }

        enabled: parent.rotatable && !parent.locked

        onClicked: if(clickable) entity.clicked(mouse)
        onPressed: entity.pressed(mouse)
        onReleased: entity.released(mouse)
        onPositionChanged: entity.positionChanged(mouse)
    }

    // Movement
    function moveTo(x,y) {
        mover.moveTo(x,y)
    }

    function pushMove(x,y) {
        mover.pushMove(x,y)
    }

    function popMove() {
        return mover.popMove()
    }

    function startMoving() {
        mover.start()
    }

    property alias mover: mover
    Mover {
        id: mover
        paused: parent.paused
        locked: parent.locked
    }

    Item {
        id: container
        anchors { fill: parent }
    }

}
