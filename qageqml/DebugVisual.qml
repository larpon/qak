import QtQuick 2.5

Rectangle {
    anchors.fill: parent

    visible: core.debug
    enabled: visible

    color: "transparent"
    border.color: "red"
    border.width: 1
}
