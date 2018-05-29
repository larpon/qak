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
        when: syncs.to && rotator.pressed
    }

    Connections {
        target: syncs.from && rotator.target ? rotator.target : null
        onRotationChanged: if(!rotator.pressed) internal.setRotation(target.rotation)
    }

    property alias sync: syncs
    QtObject {
        id: syncs
        property bool to: true
        property bool from: true
    }

    property bool paused: false
    property alias continuous: internal.continuous
    property alias continuousInfinite: internal.continuousInfinite
    property alias continuousMin: internal.continuousMin
    property alias continuousMax: internal.continuousMax

    property alias wrap: internal.wrap

    property alias min: internal.min
    property alias max: internal.max

    readonly property alias startRotation: internal.startRotation
    readonly property alias angle: internal.rotation
    readonly property alias delta: internal.delta

    readonly property var setRotation: internal.setRotation

    MouseRotatePrivate {
        id: internal

        property real prevHandleRotation: 0
        property real startRotation: 0
        property real delta: 0
    }

    signal rotate(real degree, real delta)

    function calculateRotation(point) {

        var rx = 0,
            ry = 0

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

        var diffX = (point.x - rx),
            diffY = -1 * (point.y - ry),
            rad = Math.atan (diffY / diffX),
            deg = (rad * 180 / Math.PI),
            rotation = 0

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

        var point = mapToItem(target.parent, mouse.x, mouse.y),
            rotation = calculateRotation(point)

        internal.delta = 0
        internal.prevHandleRotation = rotation
        internal.startRotation = rotation - internal.rotation //target.rotation
    }

    onPositionChanged: {
        if(!enabled || paused)
            return

        var point = mapToItem(target.parent, mouse.x, mouse.y),
            rotation = calculateRotation(point),
            delta = rotation - internal.prevHandleRotation
        internal.prevHandleRotation = rotation
        if(continuous) {
            if(Math.abs(delta) > 180) // NOTE Safe-guard when the rotation calculation flips from 360 to 0
                return
            internal.delta = delta
            internal.setRotation(internal.rotation + internal.delta)
            rotate(rotation, internal.delta)
        } else {
            internal.delta = delta
            var r = rotation - internal.startRotation
            internal.setRotation(r)
            rotate(rotation, internal.delta)
        }
    }


}
