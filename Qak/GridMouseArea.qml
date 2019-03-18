import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0

MouseArea {
    id: mouseArea

    // If no grid is sat or it's empty - be a normal mouse area
    property bool normalWhenEmpty: true

    property int columns: validGrid ? grid[0].length : 0
    property int rows: validGrid ? grid.length : 0

    readonly property real cellWidth: columns > 0 ? (width/columns) : 0
    readonly property real cellHeight: rows > 0 ? (height/rows) : 0

    readonly property bool validGrid: !Aid.undefinedOrNull(grid) && Aid.isArray(grid) && Aid.isArray(grid[0])
    // A 2D JavaScript Array of boolean values
    // Example 3x3 grid:
    // [
    //    [ false, false, false ],
    //    [ false, true, false ],
    //    [ false, false, false ]
    // ]
    property var grid

    property var __math_ceil: Math.ceil

    function setGridValue(cellPoint, value) {
        if(!validGrid)
            return false
        if(!(cellPoint))
            return false
        if(!validCellPoint(cellPoint))
            return false
        grid[cellPoint.y][cellPoint.x] = value
        var t = grid; grid = t
    }

    function getGridValue(cellPoint, value) {
        if(!validGrid)
            return false
        if(!(cellPoint))
            return false
        if(!validCellPoint(cellPoint))
            return false
        return grid[cellPoint.y][cellPoint.x]
    }

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
        // NOTE the input grid is "row major" thus we need to look up as grid[y][x]
        var cellIdx = cellIndex(point)
        if(Aid.undefinedOrNull(cellIdx)) {
            Qak.warn(Qak.gid+'GridMouseArea','::pointInGrid','cell index for point',point.x,point.y,'invalid',cellIdx)
            return false
        }

        return grid[cellIdx.y][cellIdx.x]
    }

    function cellIndex(point) {
        if(!validGrid)
            return null
        if(Aid.undefinedOrNull(point))
            return null
        // Corner case fix (we substract 1 from the grid point)
        if(point.x === 0) point.x++
        if(point.y === 0) point.y++

        if(point.x < 0 || point.x > width)
            return null
        if(point.y < 0 || point.y > height)
            return null
        var p =  Qt.point(__math_ceil((point.x * columns) / width)-1,__math_ceil((point.y * rows) / height)-1)
        if(Aid.isArray(grid) && (p.y < 0 || p.y > grid.length-1))
            return null
        if(p.y < 0 || p.y > height)
            return null
        return p
    }

    function validCellPoint(cellPoint) {
        if(!validGrid)
            return false
        if((cellPoint.y < 0 || cellPoint.y > grid.length-1))
            return false
        if(cellPoint.x < 0 || !grid[cellPoint.y] || cellPoint.x > grid[cellPoint.y].length-1)
            return false
        return true
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
//            Qak.debug(Qak.gid+'GridMouseArea','.onPressed',mouse.accepted ? 'accepted' : 'not accepted') //¤qakdbg
            return
        }
        mouse.accepted = false
//        Qak.debug(Qak.gid+'GridMouseArea','.onPressed',mouse.accepted ? 'accepted' : 'not accepted') //¤qakdbg
    }

    onClicked: {
//        Qak.debug(Qak.gid+'GridMouseArea','.onClicked',mouse.x,mouse.y) //¤qakdbg
        if(has(mouse)) {
            mouse.accepted = true
//            Qak.debug(Qak.gid+'GridMouseArea','.onClicked',mouse.accepted ? 'accepted' : 'not accepted') //¤qakdbg
            return
        }
        mouse.accepted = false
//        Qak.debug(Qak.gid+'GridMouseArea','.onClicked',mouse.accepted ? 'accepted' : 'not accepted') //¤qakdbg
    }

}
