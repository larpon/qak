import QtQuick 2.0

import Qak 1.0

MouseArea {
    id: rotator

    propagateComposedEvents: true

    enabled: true

    //readonly property var container: target.parent
    property var target: parent
    //property variant handle: parent

    property bool paused: false
    property bool continuous: false

    readonly property real startRotation: internal.startRotation
    readonly property real angle: internal.rotation

    /*
    Connections {
        target: target ? target : null
        onRotationChanged: {
            if(continuous) {
                var v = target.rotation - internal.lastRotationValue
                console.debug(':::',v)
                if(Math.abs(v) <= 358)
                    internal.rotation += v
                internal.lastRotationValue = target.rotation
            } else
                internal.rotation = target.rotation
        }
    }*/

    QtObject {
        id: internal
        property real rotation: 0
        property real startRotation: 0

        property real lastRotationValue: 0
    }

    signal rotate(real degree)

    function calculateRotation(point) {

        var rx = 0
        var ry = 0

        var pto = target.transformOrigin
        if(pto == Item.Center) {
            rx = rotator.target.width / 2; ry = rotator.target.height / 2
        } else if(pto == Item.TopLeft) {
            rx = 0; ry = 0;
        } else if(pto == Item.Left) {
            rx = 0; ry = rotator.target.height / 2
        } else if(pto == Item.BottomLeft) { // Untested
            rx = 0; ry = rotator.target.height
        } else if(pto == Item.Bottom) {
            rx = rotator.target.width / 2; ry = rotator.target.height
        } else if(pto == Item.BottomRight) {  // Untested
            rx = rotator.target.width; ry = rotator.target.height
        } else if(pto == Item.Right) {  // Untested
            rx = rotator.target.width; ry = rotator.target.height / 2
        } else if(pto == Item.TopRight) {  // Untested
            rx = rotator.target.width; ry = 0
        } else if(pto == Item.Top) {  // Untested
            rx = rotator.target.width / 2; ry = 0
        }

        rx += rotator.target.x
        ry += rotator.target.y

        var diffX = (point.x - rx)
        var diffY = -1 * (point.y - ry)
        var rad = Math.atan (diffY / diffX)
        var deg = (rad * 180 / Math.PI)

        var rotation = 0

        if (diffX > 0 && diffY > 0) {
            rotation += 90 - Math.abs (deg)
        }
        else if (diffX > 0 && diffY < 0) {
            rotation += 90 + Math.abs (deg)
        }
        else if (diffX < 0 && diffY > 0) {
            rotation += 270 + Math.abs (deg)
        }
        else if (diffX < 0 && diffY < 0) {
            rotation += 270 - Math.abs (deg)
        }

        return rotation
    }

    onPressed: {
        if(!enabled || paused)
            return

        internal.lastRotationValue = 0

        var point = mapToItem(target.parent, mouse.x, mouse.y)

        var rotation = calculateRotation(point)

        internal.startRotation = rotation - target.rotation
    }

    onPositionChanged: {
        if(!enabled || paused)
            return

        var point = mapToItem(target.parent, mouse.x, mouse.y)

        var rotation = calculateRotation(point)

        var r = rotation - internal.startRotation

        if(continuous) {
            var v = rotation - internal.lastRotationValue
            console.debug(':::',v,Math.abs(rotation))
            //if(v) {


            //}
            internal.rotation += v
            internal.lastRotationValue = internal.rotation
            //internal.lastRotationValue = internal.rotation
        } else
            internal.rotation = r

        if(!paused)
            target.rotation = internal.rotation

        //Qak.debug(rotation)

        rotate(rotation)
    }


}
