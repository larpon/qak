import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0

GridMouseArea {

    id: walkMap

    //property point startPosition: Qt.point(0,0)
    //property point endPosition: Qt.point(0,0)

    property bool simplify: false

    property var __remappedGrid
    property var __solvesList: ({})
    property int __nextSolveId: 0

    signal sameCell
    signal error

    onGridChanged: {
        if(validGrid) {
//            Qak.debug(Qak.gid+'WalkMap','onGridChanged','reading to remapped grid') //¤qakdbg
            __remappedGrid = []
            var i ,j
            for(i in grid) {
                var r = []
                for(j in grid[i]) {
                    if(grid[i][j])
                        r[j] = 0
                    else
                        r[j] = 1
                }
                __remappedGrid[i] = r
            }
        }
    }

    onValidGridChanged: {
        if(validGrid) {
//            Qak.debug(Qak.gid+'WalkMap','onValidGridChanged','reading to remapped grid') //¤qakdbg
            __remappedGrid = []
            var i ,j
            for(i in grid) {
                var r = []
                for(j in grid[i]) {
                    if(grid[i][j])
                        r[j] = 0
                    else
                        r[j] = 1
                }
                __remappedGrid[i] = r
            }
        }
    }

    // Functionality
    WorkerScript {
        id: solverWorker
        source: "./js/walkMapWorker.js"

        onMessage: {
//            Qak.debug(Qak.gid+'WalkMap','>solverWorker.onMessage','path was',messageObject.found ? 'found' : 'not found') //¤qakdbg
            if(messageObject.found) {
                __solvesList[messageObject.solveId].onFound(pathToPoints(messageObject.path))
            } else
                __solvesList[messageObject.solveId].onNotFound()
            if('solveId' in messageObject) {
//                Qak.debug(Qak.gid+'WalkMap','>solverWorker.onMessage','removing solve id',messageObject.solveId) //¤qakdbg
                //delete __solvesList[messageObject.solveId]
                __solvesList[messageObject.solveId] = undefined
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
    // TODO do this in the worker script?
    function pathToPoints(path) {
        //var referenceChild = grid.children[0]
        var offset = Qt.point(cellWidth,cellHeight)
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
//            Qak.debug(Qak.gid+'WalkMap','::pathToPoints','simplifing walk path. Before simplify',points.length) //¤qakdbg
            points = simplifyPath(points, 2.5)
//            Qak.debug(Qak.gid+'WalkMap','::pathToPoints','after simplify', points.length) //¤qakdbg
        }

        return points
    }

    function findPath(startPoint, endPoint, onFound, onNotFound, onInSameCell) {

        var startPos = cellIndex(startPoint)
        var endPos = cellIndex(endPoint)

        if(Aid.undefinedOrNull(startPos) || Aid.undefinedOrNull(endPos)) {
            Qak.error(Qak.gid+'WalkMap','::findPath','start or end point(s) invalid','start:',startPos,'end:',endPos)
            error()
            return
        }

        if(startPos.x === endPos.x && startPos.y === endPos.y) {
            Qak.info(Qak.gid+'WalkMap','::findPath','start and end point are in same cell')
            if(Aid.isFunction(onInSameCell)) onInSameCell()
            sameCell()
            return
        }

        // NOTE endPoint values might be undefined in debug output - this is because the refence can be a 'mouse' event - which gets garbage collected before debug outputs is buffer.
//        Qak.debug(Qak.gid+'WalkMap','::findPath',"start (cell)",startPos.x,startPos.y,"end (cell)",endPos.x,endPos.y,' - ','start (point)',startPoint.x,startPoint.y,'end (point)',endPoint.x,endPoint.y) //¤qakdbg

        __solvesList[__nextSolveId] = { 'onFound':onFound, 'onNotFound':onNotFound }
        solverWorker.sendMessage( { 'solveId': __nextSolveId, 'grid': __remappedGrid, 'startPosition': startPos, 'endPosition': endPos } )
        __nextSolveId++
    }

}
