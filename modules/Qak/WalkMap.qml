import QtQuick 2.5

import QakQuick 1.0

Entity {

    id: walkMap

    property alias grid: grid
    property alias columns: grid.columns
    property alias rows: grid.rows

    property bool edit: false
    property bool visualize: false

    property point startPosition: Qt.point(0,0)
    property point endPosition: Qt.point(0,0)

    property bool simplify: true

    property var solvesList: ({})
    property int nextSolveId: 0
    // Functionality
    WorkerScript {
        id: solverWorker
        source: "./js/walkMapWorker.js"

        onMessage: {
            Qak.db('Path was found?',messageObject.found)
            if(messageObject.found) {
                solvesList[messageObject.solveId].onFound(pathToPoints(messageObject.path))
            } else
                solvesList[messageObject.solveId].onNotFound()
            if('solveId' in messageObject) {
                Qak.db('Removing',messageObject.solveId)
                delete solvesList[messageObject.solveId]
            }
        }
    }

    // https://gist.github.com/adammiller/826148
    function simplifyPath( points, tolerance ) {

        // helper classes
        var Vector = function( x, y ) {
            this.x = x;
            this.y = y;

        };
        var Line = function( p1, p2 ) {
            this.p1 = p1;
            this.p2 = p2;

            this.distanceToPoint = function( point ) {
                // slope
                var m = ( this.p2.y - this.p1.y ) / ( this.p2.x - this.p1.x ),
                    // y offset
                    b = this.p1.y - ( m * this.p1.x ),
                    d = [];
                // distance to the linear equation
                d.push( Math.abs( point.y - ( m * point.x ) - b ) / Math.sqrt( Math.pow( m, 2 ) + 1 ) );
                // distance to p1
                d.push( Math.sqrt( Math.pow( ( point.x - this.p1.x ), 2 ) + Math.pow( ( point.y - this.p1.y ), 2 ) ) );
                // distance to p2
                d.push( Math.sqrt( Math.pow( ( point.x - this.p2.x ), 2 ) + Math.pow( ( point.y - this.p2.y ), 2 ) ) );
                // return the smallest distance
                return d.sort( function( a, b ) {
                    return ( a - b ); //causes an array to be sorted numerically and ascending
                } )[0];
            };
        };

        var douglasPeucker = function( points, tolerance ) {
            if ( points.length <= 2 ) {
                return [points[0]];
            }
            var returnPoints = [],
                // make line from start to end
                line = new Line( points[0], points[points.length - 1] ),
                // find the largest distance from intermediate poitns to this line
                maxDistance = 0,
                maxDistanceIndex = 0,
                p;
            for( var i = 1; i <= points.length - 2; i++ ) {
                var distance = line.distanceToPoint( points[ i ] );
                if( distance > maxDistance ) {
                    maxDistance = distance;
                    maxDistanceIndex = i;
                }
            }
            // check if the max distance is greater than our tollerance allows
            if ( maxDistance >= tolerance ) {
                p = points[maxDistanceIndex];
                line.distanceToPoint( p, true );
                // include this point in the output
                returnPoints = returnPoints.concat( douglasPeucker( points.slice( 0, maxDistanceIndex + 1 ), tolerance ) );
                // returnPoints.push( points[maxDistanceIndex] );
                returnPoints = returnPoints.concat( douglasPeucker( points.slice( maxDistanceIndex, points.length ), tolerance ) );
            } else {
                // ditching this point
                p = points[maxDistanceIndex];
                line.distanceToPoint( p, true );
                returnPoints = [points[0]];
            }
            return returnPoints;
        };
        var arr = douglasPeucker( points, tolerance );
        // always have to push the very last point on so it doesn't get left off
        arr.push( points[points.length - 1 ] );
        return arr;
    }

    // Convert x,y values from the grid to actual pixel coordinates
    function pathToPoints(path) {
        //var referenceChild = grid.children[0]
        var offset = Qt.point(grid.cellWidth,grid.cellHeight)
        var points = []
        for(var i in path) {
            var pos = path[i]
            //console.debug('Path x,y',pos.x,pos.y)
            pos.x = Math.round((offset.x * pos.x) + offset.x/2)
            pos.y = Math.round((offset.y * pos.y) + offset.y/2)

            points[i] = pos
            //console.debug('Points x,y',pos.x,pos.y)
        }

        if(simplify) {
            Qak.db('Simplifing walk path. Before simplify',points.length)
            points = simplifyPath(points, 2.5)
            Qak.db('after simplify', points.length)
        }

        return points
    }

    function findPath(startPoint, endPoint, onFound, onNotFound) {

        // Fix point extremes
        if(startPoint.x <= 0) {
            Qak.warn('Fixed start point.x 0')
            startPoint.x = Number.MIN_VALUE
        }
        if(startPoint.y <= 0) {
            Qak.warn('Fixed start point.y 0')
            startPoint.y = Number.MIN_VALUE
        }
        if(endPoint.x <= 0) {
            Qak.warn('Fixed end point.x 0')
            endPoint.x = Number.MIN_VALUE
        }
        if(endPoint.y <= 0) {
            Qak.warn('Fixed end point.y 0')
            endPoint.y = Number.MIN_VALUE
        }

        if(startPoint.x >= walkMap.width) {
            Qak.warn('Fixed start point.x',walkMap.width)
            startPoint.x -= Number.MIN_VALUE
        }
        if(startPoint.y >= walkMap.height) {
            Qak.warn('Fixed start point.y', walkMap.height)
            startPoint.y -= Number.MIN_VALUE
        }
        if(endPoint.x >= walkMap.width) {
            Qak.warn('Fixed end point.x',walkMap.width)
            endPoint.x = Number.MIN_VALUE
        }
        if(endPoint.y >= walkMap.height) {
            Qak.warn('Fixed end point.y', walkMap.height)
            endPoint.y = Number.MIN_VALUE
        }

        if(walkMap.x > 0) {
            startPoint.x = startPoint.x - walkMap.x
            endPoint.x = endPoint.x - walkMap.x
        }
        if(walkMap.y > 0) {
            startPoint.y = startPoint.y - walkMap.y
            endPoint.y = endPoint.y - walkMap.y
        }

        var child = grid.childAt(startPoint.x,startPoint.y)
        child.show = true
        var idx = child.idx
        var times = Math.floor(idx/grid.columns)
        Qak.db('start grid box',idx, times)
        startPosition.x = idx-(times*grid.columns)
        startPosition.y = times

        child = grid.childAt(endPoint.x, endPoint.y)
        child.show = true
        idx = child.idx
        times = Math.floor(idx/grid.columns)
        Qak.db('end grid box',idx,times)
        endPosition.x = idx-(times*grid.columns)
        endPosition.y = times

        var cs = []
        var rs = []
        for(var i = 0; i < grid.children.length-1; i++) {
            child = grid.children[i]



            if(child.on) {
                Qak.db('adding child at index',i,child.idx)
                rs.push(0)
            } else
                rs.push(1)

            if(rs.length % grid.columns === 0) {
                var c = rs.slice()
                cs.push(c)
                rs = []
            }
        }

        Qak.db("Start position",startPosition.x,startPosition.y,"end position",endPosition.x,endPosition.y)

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

        readonly property real cellWidth: (width/columns)
        readonly property real cellHeight: (height/rows)

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
