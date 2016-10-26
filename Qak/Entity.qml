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

    property bool locked: false
    property bool draggable: false
    property bool rotatable: false

    property bool adaptSource: true
    property string adaptiveSource: ""
    property alias source: adaptive.source

    property Item viewport: findViewport(entity)

    signal clicked(var mouse)

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

    Item {
        id: container
        anchors.fill: parent
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

    function goBack() {
        dragMoveBackAnimation.running = true
    }

    MouseArea {
        id: drag

        property int ox: draggable ? entity.x : 0
        property int oy: draggable ? entity.y : 0

        enabled: parent.draggable && !parent.locked
        //visible: enabled

        property bool dragging: false

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
            //Qak.debug('drag started',entity)
            dragging = true
            dragStarted(mouse)
        }

        onReleased: {
            if(entity.Drag.drop() !== Qt.IgnoreAction) {
                //Qak.debug('drag accepted',entity)
                dragAccepted(mouse)
            } else {
                //Qak.debug('drag rejected',entity)
                dragRejected(mouse)
                goBack()
            }
            //Qak.debug('drag ended',entity)
            dragEnded(mouse)
            dragging = false
        }

        onPositionChanged: {
            var map = entity.mapToItem(entity.parent,mouse.x,mouse.y)
            dragged(mouse,map)
        }

        onClicked: entity.clicked(mouse)

        function goBack() {
            if(dragReturnOnReject) {
                dragMoveBackAnimation.running = true
                //Qak.debug('drag return',entity)
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
                //Qak.debug('drag returned',entity)
                entity.dragReturned()
            }}
        }
    }

    Drag.active: drag.drag.active
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2

    // Mouse rotate functionality
    property alias rotator: rotator
    MouseRotator {
        id: rotator
        enabled: parent.rotatable && !parent.locked

        onClicked: entity.clicked(mouse)

        anchors.fill: parent
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
        mover.startMoving()
    }

    property alias mover: mover
    Mover {
        id: mover
        locked: parent.locked
    }
}
