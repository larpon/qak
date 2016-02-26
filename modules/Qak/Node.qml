import QtQuick 2.5

import Qak 1.0

Item {
    id: node

    objectName: "QakNode"

    property string tag: "node"

    property var t
    property bool q: false

    property Item ref

    property bool running: false

    readonly property Item root: findRoot(node)

    readonly property bool isRoot: (parent.objectName !== "QakNode")
    readonly property bool isLeaf: (children.length <= 0)
    readonly property bool isLast: (!isRoot && parent.children[parent.children.length-1] === node)

    function findRoot(item) {
        if(item.objectName === "QakNode" && item.isRoot)
            return item
        else
            return findRoot(item.parent)
    }

}
