import QtQuick 2.0

//import Qak 1.0 //¤qakdbg
import Qak.Tools 1.0

MouseArea {
    id: mouseArea

    // If no polygon is sat or it's empty - be a normal mouse area
    property bool normalWhenEmpty: true

    // A JavaScript Array of { x: <number>, y: <number> } objects
    property var polygon: ([])

    readonly property bool validPolygon: polygon && Aid.isArray(polygon) && polygon.length > 2 && polygon[0] && ('x' in polygon[0]) && ('y' in polygon[0])

    // https://gist.github.com/johannesboyne/5626235
    // http://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html
    function pointInPolygon(point, points) {
        var x = point.x, y = point.y;
        var inside = false;
        for (var i = 0, j = points.length - 1; i < points.length; j = i++) {
            var xi = points[i].x, yi = points[i].y;
            var xj = points[j].x, yj = points[j].y;

            var intersect = ((yi > y) != (yj > y))
                && (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
            if (intersect) inside = !inside;
        }

//        Qak.debug(Qak.gid+'PolygonMouseArea','point',point.x,point,y,'in polygon',inside) //¤qakdbg
        return inside;
    }

    function has(mouse) {
        if(!enabled)
            return false
        if(normalWhenEmpty && !validPolygon)
            return contains(Qt.point(mouse.x,mouse.y))
        return pointInPolygon(mouse,polygon)
    }

    onPressed: {
//        Qak.debug(Qak.gid+'PolygonMouseArea','pressed',mouse.x,mouse.y) //¤qakdbg
        if(has(mouse)) {
            mouse.accepted = true
            return
        }
        mouse.accepted = false
    }

    onClicked: {
//        Qak.debug(Qak.gid+'PolygonMouseArea','clicked',mouse.x,mouse.y) //¤qakdbg
        if(has(mouse)) {
            mouse.accepted = true
            return
        }
        mouse.accepted = false
    }

}
