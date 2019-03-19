import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.3

import "console.js" as Util

Item {
    id: root
    ColumnLayout {
        anchors { fill: parent }
        anchors.margins: 9
        RowLayout {
            Layout.fillWidth: true
            TextField {
                id: input
                Layout.fillWidth: true
                focus: true
                onAccepted: {
                    // call our evaluation function on root
                    root.jsCall(input.text)
                }
            }
            Button {
                text: qsTr("Send")
                onClicked: {
                    // call our evaluation function on root
                    root.jsCall(input.text)
                }
            }
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Rectangle {
                anchors { fill: parent }
                color: '#333'
                border.color: Qt.darker(color)
                opacity: 0.2
                radius: 2
            }

            ScrollView {
                id: scrollView
                anchors { fill: parent }
                anchors.margins: 9
                ListView {
                    id: resultView
                    model: ListModel {
                        id: outputModel
                    }
                    delegate: ColumnLayout {
                        width: ListView.view.width
                        Label {
                            Layout.fillWidth: true
                            color: 'green'
                            text: "> " + model.expression
                        }
                        Label {
                            Layout.fillWidth: true
                            color: 'blue'
                            text: "" + model.result
                        }
                        Rectangle {
                            height: 1
                            Layout.fillWidth: true
                            color: '#333'
                            opacity: 0.2
                        }
                    }
                }
            }
        }
    }

    function jsCall(exp) {
        var data = Util.call(exp);
        // insert the result at the beginning of the list
        outputModel.insert(0, data)
    }
}
