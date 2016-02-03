import QtQuick 2.5

import "./js/easystar-0.2.3.js" as EasyStar

Entity {

    id: walkPath

    property var pathFinder: new EasyStar.EasyStar.Js();
    property alias columns: grid.columns
    property alias rows: grid.rows

    property int startPositionX: 0
    property int startPositionY: 0
    property int endPositionX: 0
    property int endPositionY: 0

    Grid {
        id: grid

        anchors.fill: parent
        columns: 10
        rows: 5

        property real cellWidth: (width/columns)
        property real cellHeight: (height/rows)

        Repeater {
            model: (parent.columns*parent.rows)
            Rectangle {

                width: parent.cellWidth
                height: parent.cellHeight

                opacity: 0.32

                color: on ? "green" : "transparent"

                property bool on: false
                property bool show: false

                property int idx: index

                Rectangle {
                    id: mixer
                    anchors.fill: parent

                    visible: parent.show
                    opacity: 0.32

                    color: "blue"
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        property Item current

        onCurrentChanged: current.on = !current.on

        onPressed: current = grid.childAt(mouse.x,mouse.y)
        onPositionChanged: current = grid.childAt(mouse.x,mouse.y)

        //focus: true
        Keys.onPressed: {
            db('Walk Path',"Got key event",event,event.key)

            var key = event.key

            if (key === Qt.Key_1) {
                var idx = grid.childAt(mouseArea.mouseX,mouseArea.mouseY).idx
                var times = Math.floor(idx/grid.columns)
                startPositionX = idx-(times*grid.columns)
                startPositionY = times
                db("Recording start position",startPositionX,startPositionY)
            }

            if (key === Qt.Key_2) {
                var idx = grid.childAt(mouseArea.mouseX,mouseArea.mouseY).idx
                var times = Math.floor(idx/grid.columns)
                endPositionX = idx-(times*grid.columns)
                endPositionY = times
                db("Recording end position",endPositionX,endPositionY)
            }

            if (key === Qt.Key_3) {
                pathFinder.enableSync()
                var cs = []
                var rs = []
                for(var i = 0; i < grid.children.length-1; i++) {
                    var child = grid.children[i]

                    //db(i+1,child.ix,child.iy)

                    if(child.on)
                        rs.push(0)
                    else
                        rs.push(1)

                    if(rs.length % grid.columns === 0) {
                        var c = rs.slice()
                        cs.push(c)
                        rs = []

                    }


                }
                for(var i in cs) {
                    var d = cs[i]
                    db(d)

                }
                //db(cs[0])
                /*
                var agrid = [[0,0,1,0,0],
                            [0,0,1,0,0],
                            [0,0,1,0,0],
                            [0,0,1,0,0],
                            [0,0,0,0,0]];
                */

                pathFinder.setGrid(cs);

                pathFinder.setAcceptableTiles([0]);

                pathFinder.findPath(startPositionX, startPositionY, endPositionX, endPositionY, function( path ) {
                    if (path === null) {
                        db("Path was not found.")
                    } else {
                        db("Path was found.")
                        for(var i in path) {
                            var pos = path[i]
                            db(pos.x,pos.y)
                        }
                    }
                });

                pathFinder.calculate();
            }

        }
    }
}
