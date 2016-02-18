
import QtQuick 2.5

import Qak 1.0

import "qakqml" as QuickQak

import "qml" as Test

QuickQak.Core {
    id: core

    width: 800
    height: 400

    //color: "transparent"

    debug: true

    //fillmode: Image.Stretch

    viewport.width: 1100
    viewport.height: 660

    //canvas.width: 1400
    //canvas.height: 700


    // Canvas modification examples

    /*

    //canvas.x: -(canvas.width-viewportWidth)/2
    //canvas.y: -(canvas.height-viewportHeight)/2

    Behavior on canvas.x {
        NumberAnimation { duration: 1000 }
    }

    Behavior on canvas.scale {
        NumberAnimation { duration: 1000 }
    }

    MouseArea {
        id: canvasExampleController
        anchors.fill: parent

        readonly property point viewportPosition: mapToItem(viewport,position.x,position.y)
        readonly property point position: Qt.point(canvasExampleController.mouseX, canvasExampleController.mouseY)

        hoverEnabled: true

        onPositionChanged: {
            //db('xy',viewportPosition.x, viewportPosition.y)
            var xHalfDiff = (canvas.width-viewport.width)
            var yHalfDiff = (canvas.height-viewport.height)/2

            // Scroll when close to 1/4 the width of the viewport
            if(viewportPosition.x <= (viewport.width/4)) {
                canvas.x = 0
            } else if(viewportPosition.x > (viewport.width/4)*3) {
                canvas.x = -xHalfDiff
            } else
                canvas.x = -xHalfDiff/2

            // Scroll within area
            //var nx = clamp(remap(viewportPosition.x,0,viewportWidth,0+100,-xHalfDiff-100),-xHalfDiff,0)
            //canvas.x = nx
            //db(nx)
        }

        // Scale the canvas
        onWheel: {
            if (wheel.modifiers & Qt.ControlModifier) {
                canvas.scale += wheel.angleDelta.y / 120 * 5;

            } else {
                canvas.scale += wheel.angleDelta.x / 120;

                var scaleBefore = canvas.scale;
                canvas.scale += canvas.scale * wheel.angleDelta.y / 120 / 10;
            }
        }
    }

    Item {
        id: canvasMover

        property QtObject controller: canvasExampleController

        Connections {
            target: canvasExampleController

            property alias x: canvasExampleController.position.x
            property alias y: canvasExampleController.position.y

            property alias vpx: canvasExampleController.viewportPosition.x
            property alias vpy: canvasExampleController.viewportPosition.y

            property alias canvas: core.canvas
            property alias viewport: core.viewport

            onPositionChanged: {
                //db(x, y, vpx, vpy, viewport.scaledWidth)
                //db(vpx, viewport.scaledWidth)
                if(vpx > 0 && vpx <= (viewport.width/2)) {
                    db('canvas x',canvas.x)
                } else if(vpx > (viewport.width/2)) {
                    db('in right part')
                } else
                    db('mid')

            }
        }

    }
    */

    // Example engine items

    /*
    Qak.Entity {
        id: entity
        anchors.fill: parent

        source: "canvas_test_1400x700.png"

        Image {
            anchors.fill: parent
            source: entity.adaptiveSource
        }
    }
    */

    // Adaptive source example
    QuickQak.Entity {
        id: entity
        anchors.fill: parent

        source: "test.png"

        Image {
            anchors.fill: parent
            source: entity.adaptiveSource
        }
    }

    // Movement example
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {

            if (mouse.button == Qt.RightButton)
                spriteTest.startMoving()
            else {
                spriteTest.pushMove(mouse.x,mouse.y)
                spriteTest2.moveTo(mouse.x,mouse.y)
            }

        }
    }

    // Walk map example
    QuickQak.WalkMap {
        id: walkMap

        anchors.fill: parent

        columns: 60

        MouseArea {
            id: mouseArea
            anchors.fill: parent

            property Item current

            onCurrentChanged: current.on = !current.on

            onPressed: current = walkMap.grid.childAt(mouse.x,mouse.y)
            onPositionChanged: current = walkMap.grid.childAt(mouse.x,mouse.y)

            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: {
                if(mouse.button & Qt.RightButton) {
                    walkMap.findPath(Qt.point(0,0), Qt.point(walkMap.width-1,walkMap.height-1),
                    function(path){
                        db('callback found',path)
                        for(var i in path) {
                            spriteTest.pushMove(path[i].x,path[i].y)
                        }
                        spriteTest.startMoving()
                    }, function(){
                        db('callback NOT found')
                    })
                }
            }
        }
    }


    // Wrong source error examples
    QuickQak.Image {
        id: errorTestSprite
        x: 430
        y: 80
        width: 120
        height: width
        source: "test_error.png"
        MouseArea {
            anchors.fill: parent
            onClicked: {

                errorTestSprite.source = "test.x-2.png"

                //canvas.rotation = 40
            }
        }
    }

    QuickQak.Image {
        id: error2TestSprite
        x: 400
        y: 400
        width: 120
        height: width
        MouseArea {
            anchors.fill: parent
            onClicked: {
                error2TestSprite.source = "test.png"
            }
        }
    }

    QuickQak.Image {
        id: testSprite1
        x: 20
        y: 350
        width: viewport.width*0.2
        height: viewport.height*0.2
        source: "test.png"
    }

    // Drag 'n' drop example
    QuickQak.Entity {
        x: 600
        y: 400
        width: 70
        height: width

        Rectangle {
            anchors.fill: parent
            color: "green"
        }

        DropArea {
            keys: [ "test_drop" ]
            anchors.fill: parent
            onDropped: {
                drop.accept()
            }
        }
    }

    QuickQak.Entity {

        x: 200
        y: 200
        width: 30
        height: width

        draggable: true
        Drag.keys: "test_drop"

        Rectangle {
            anchors.fill: parent
            color: "tomato"
        }
    }

    // Rotation example

    QuickQak.Entity {
        rotatable: true
        anchors.centerIn: parent
        width: 50
        height: width

        Rectangle {
            anchors.fill: parent
            color: "orange"

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 10
                color: "blue"
            }
        }
    }

    /*
    Test.SittingMan {
        x: 200
        y: 40
        width: 128
        height: 216
    }
    */

    QuickQak.Sprite {
        id: spriteTest

        width: 128
        height: 216

        source: "sitting_man/0001.png"

    }


    QuickQak.Entity {
        id: spriteTest2

        rotatable: true

        x: parent.halfWidth-halfWidth; y: parent.halfHeight-halfHeight

        width: 128
        height: 216

        QuickQak.Sprite {
            id: spriteTest2Sprite

            anchors.fill: parent

            source: "sitting_man/0001.png"

            MouseArea {
                anchors.fill: parent
                onClicked: spriteTest2Sprite.setActiveSequence('sit')
            }
        }
    }

    QuickQak.Image {
        x: (parent.width/4)*3
        y: 0
        width: 200
        height: width

        source: "test.png"

        QuickQak.MouseRotator {
            anchors.fill: parent
        }
    }



}
