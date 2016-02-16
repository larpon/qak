import QtQuick 2.5

Entity {

    id: walkMap

    property alias grid: grid
    property alias columns: grid.columns
    property alias rows: grid.rows

    property bool edit: false
    property bool visualize: false

    property point startPosition: Qt.point(0,0)
    property point endPosition: Qt.point(0,0)

    property var solvesList: ({})
    property int nextSolveId: 0
    // Functionality
    WorkerScript {
        id: solverWorker
        source: "./js/walkMapWorker.js"

        onMessage: {
            db('Path was found?',messageObject.found)
            if(messageObject.found) {
                solvesList[messageObject.solveId].onFound(pathToCoords(messageObject.path))
            } else
                solvesList[messageObject.solveId].onNotFound()
            if('solveId' in messageObject) {
                db('Removing',messageObject.solveId)
                delete solvesList[messageObject.solveId]
            }
        }
    }

    function pathToCoords(path) {
        for(var i in path) {
            var pos = path[i]
            //console.debug('Path x,y',pos.x,pos.y)
        }
        return path
    }

    function findPath(startPoint, endPoint, onFound, onNotFound) {

        // Fix point extremes
        if(startPoint.x <= 0) {
            warn('Fixed start point.x 0')
            startPoint.x = Number.MIN_VALUE
        }
        if(startPoint.y <= 0) {
            warn('Fixed start point.y 0')
            startPoint.y = Number.MIN_VALUE
        }
        if(endPoint.x <= 0) {
            warn('Fixed end point.x 0')
            endPoint.x = Number.MIN_VALUE
        }
        if(endPoint.y <= 0) {
            warn('Fixed end point.y 0')
            endPoint.y = Number.MIN_VALUE
        }

        if(startPoint.x >= walkMap.width) {
            warn('Fixed start point.x',walkMap.width)
            startPoint.x -= Number.MIN_VALUE
        }
        if(startPoint.y >= walkMap.height) {
            warn('Fixed start point.y', walkMap.height)
            startPoint.y -= Number.MIN_VALUE
        }
        if(endPoint.x >= walkMap.width) {
            warn('Fixed end point.x',walkMap.width)
            endPoint.x = Number.MIN_VALUE
        }
        if(endPoint.y >= walkMap.height) {
            warn('Fixed end point.y', walkMap.height)
            endPoint.y = Number.MIN_VALUE
        }



        var child = grid.childAt(startPoint.x,startPoint.y)
        child.show = true
        var idx = child.idx
        var times = Math.floor(idx/grid.columns)
        db('start grid box',idx, times)
        startPosition.x = idx-(times*grid.columns)
        startPosition.y = times

        child = grid.childAt(endPoint.x, endPoint.y)
        child.show = true
        idx = child.idx
        times = Math.floor(idx/grid.columns)
        db('end grid box',idx,times)
        endPosition.x = idx-(times*grid.columns)
        endPosition.y = times

        var cs = []
        var rs = []
        for(var i = 0; i < grid.children.length-1; i++) {
            child = grid.children[i]



            if(child.on) {
                db('adding child at index',i,child.idx)
                rs.push(0)
            } else
                rs.push(1)

            if(rs.length % grid.columns === 0) {
                var c = rs.slice()
                cs.push(c)
                rs = []
            }
        }

        db("Start position",startPosition.x,startPosition.y,"end position",endPosition.x,endPosition.y)

        var startPos = { 'x':startPosition.x, 'y': startPosition.y }
        var endPos = { 'x':endPosition.x, 'y': endPosition.y }

        solvesList[nextSolveId] = { 'onFound':onFound, 'onNotFound':onNotFound }
        solverWorker.sendMessage( { 'solveId': nextSolveId, 'grid': cs, 'startPosition': startPos, 'endPosition': endPos } )
        nextSolveId++
    }

    // Visualization
    Grid {
        id: grid

        anchors.fill: parent
        columns: 10
        rows: Math.floor(columns*(height/width))

        property real cellWidth: (width/columns)
        property real cellHeight: (height/rows)

        Repeater {
            model: (parent.columns*parent.rows)
            Rectangle {

                width: parent.cellWidth
                height: parent.cellHeight

                opacity: 0.15

                color: on ? "green" : "red"

                border.width: 1
                border.color: "yellow"

                property bool on: false
                property bool show: false

                property int idx: index

                Rectangle {
                    id: mixer
                    anchors.fill: parent

                    visible: parent.show
                    opacity: 0.5

                    color: "blue"
                }
            }
        }
    }

}
