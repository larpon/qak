import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0
import Qak.Private 1.0

MouseArea {
    id: rotator

    enabled: true

    property var target: parent

    Binding {
        target: rotator.target ? rotator.target : null
        property: "rotation"
        value: internal.rotation
        when: sync && rotator.pressed
    }

    Connections {
        target: sync && rotator.target ? rotator.target : null
        onRotationChanged: if(!rotator.pressed) internal.setRotation(target.rotation)
    }

    property bool sync: true

    property bool paused: false
    property alias continuous: internal.continuous
    property alias continuousInfinite: internal.continuousInfinite
    property alias continuousMin: internal.continuousMin
    property alias continuousMax: internal.continuousMax

    property alias wrap: internal.wrap

    property alias min: internal.min
    property alias max: internal.max

    readonly property real startRotation: internal.startRotation
    readonly property real angle: internal.rotation

    readonly property var setRotation: internal.setRotation

    MouseRotatePrivate {
        id: internal

        property real prevHandleRotation: 0
        property real startRotation: 0
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
            //rotation += 90 - Math.abs (deg)
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

        if(min !== 0 || max !== 360)
            rotation = Aid.remap(rotation,0,360,min,max)
        return rotation
    }

    onPressed: {
        if(!enabled || paused)
            return

        var point = mapToItem(target.parent, mouse.x, mouse.y)

        var rotation = calculateRotation(point)

        internal.prevHandleRotation = rotation
        internal.startRotation = rotation - internal.rotation //target.rotation
    }

    onPositionChanged: {
        if(!enabled || paused)
            return

        var point = mapToItem(target.parent, mouse.x, mouse.y)

        var rotation = calculateRotation(point)

        if(continuous) {
            var traveled = rotation - internal.prevHandleRotation
            internal.prevHandleRotation = rotation
            if(Math.abs(traveled) > 180) // NOTE Safe-guard when the rotation calculation flips from 360 to 0
                return
            internal.setRotation(internal.rotation + traveled)
        } else {
            var r = rotation - internal.startRotation
            internal.setRotation(r)
        }

        rotate(rotation)
    }


}
