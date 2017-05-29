import QtQuick 2.0

//import Qak 1.0 //¤qakdbg
import Qak.Tools 1.0

MouseArea {
    id: mouseArea

    // If no grid is sat or it's empty - be a normal mouse area
    property bool normalWhenEmpty: true

    property int columns: validGrid ? grid[0].length : 0
    property int rows: validGrid ? grid.length : 0

    readonly property real cellWidth: columns > 0 ? (width/columns) : 0
    readonly property real cellHeight: rows > 0 ? (height/rows) : 0

    readonly property bool validGrid: grid && Aid.isArray(grid) && Aid.isArray(grid[0])
    // A 2D JavaScript Array of boolean values
    // Example 3x3 grid:
    // [
    //    [ false, false, false ],
    //    [ false, true, false ],
    //    [ false, false, false ]
    // ]
    property var grid

    property var __math_ceil: Math.ceil

    function pointInGrid(point,grid) {
        grid = grid || mouseArea.grid
        if(!validGrid)
            return false
        if(!(point))
            return false
        if(point.x < 0 || point.x > width)
            return false
        if(point.y < 0 || point.y > height)
            return false
        return grid[__math_ceil((point.y * rows) / height)-1][__math_ceil((point.x * columns) / width)-1]
    }

    function cellIndex(point) {
//        Qak.debug(Qak.gid+'GridMouseArea','::cellIndex',point.x,point.y,(point.y < 0 || point.y > height),height) //¤qakdbg
        if(!validGrid)
            return null
        if(!(point))
            return null
        if(point.x < 0 || point.x > width)
            return null
        if(point.y < 0 || point.y > height)
            return null
        return Qt.point(__math_ceil((point.y * rows) / height)-1,__math_ceil((point.x * columns) / width)-1)
    }

    function has(mouse) {
        if(!enabled)
            return false
        if(normalWhenEmpty && (!grid || grid.length <= 0))
            return contains(mouse)
        return pointInGrid(mouse)
    }

    onPressed: {
//        Qak.debug(Qak.gid+'GridMouseArea','.onPressed',mouse.x,mouse.y) //¤qakdbg
        if(has(mouse)) {
            mouse.accepted = true
            return
        }
        mouse.accepted = false
    }

    onClicked: {
//        Qak.debug(Qak.gid+'GridMouseArea','.onClicked',mouse.x,mouse.y) //¤qakdbg
        if(has(mouse)) {
            mouse.accepted = true
            return
        }
        mouse.accepted = false
    }

}
