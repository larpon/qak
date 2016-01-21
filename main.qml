
import QtQuick 2.5

import "qml"

Core {
    id: core

    //width: 781
    //height: 518

    targetWidth: 1100
    targetHeight: 660

    //color: "transparent"

    debug: true

    //fillmode: Image.Stretch

    QageImage {
        anchors.fill: parent
        source: "test.png"
    }


    QageSprite {
        id: errorTestSprite
        x: 500
        y: 500
        width: 120
        height: width
        //source: "test_error.png"
        MouseArea {
            anchors.fill: parent
            onClicked: {

                errorTestSprite.source = "test.x-2.png"

                //canvas.rotation = 40
            }
        }
    }

    Entity {
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

    Entity {

        x: 100
        y: 100
        width: 30
        height: width

        draggable: true
        Drag.keys: "test_drop"

        Rectangle {
            anchors.fill: parent
            color: "tomato"
        }
    }

    Entity {
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
    WalkPath {
        anchors.fill: parent

    }
    */
}
