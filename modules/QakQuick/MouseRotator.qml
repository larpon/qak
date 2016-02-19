import QtQuick 2.5

MouseArea {
    id: rotator

    propagateComposedEvents: true

    enabled: true

    //readonly property var container: target.parent
    property var target: parent
    //property variant handle: parent

    property bool pause: false

    property real startRotation: 0

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
        if(!enabled || pause)
            return

        var point = mapToItem(target.parent, mouse.x, mouse.y)

        var rotation = calculateRotation(point)

        startRotation = rotation - target.rotation
    }

    onPositionChanged: {
        if(!enabled || pause)
            return

        var point = mapToItem(target.parent, mouse.x, mouse.y)

        var rotation = calculateRotation(point)

        rotation -= startRotation

        if(!pause)
            target.rotation = rotation

        //Qak.db(rotation)

        rotate(rotation)
    }


}
