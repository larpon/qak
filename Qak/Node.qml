import QtQuick 2.0

// NOTE maybe use https://github.com/afiore/arboreal or https://github.com/aaronj1335/t-js/blob/master/t.js someday?
Item {
    id: node

    objectName: "QakNode"

    readonly property Item root: findRoot(node)

    readonly property bool isRoot: (parent.objectName !== "QakNode")
    readonly property bool isLeaf: (children.length <= 0)
    readonly property bool isLast: isRoot || (!isRoot && parent.children[parent.children.length-1] === node)

    function findRoot(item) {
        if(item.objectName === "QakNode" && item.isRoot)
            return item
        else
            return findRoot(item.parent)
    }

    function all(item,f) {
        if(f)
            f(item)
        for(var i in item.children) {
            var n = item.children[i]
            all(n,f)
        }
    }

    function backup(item,f) {
        if(f)
            f(item)
        if(!item.isRoot)
            backup(item.parent,f)
    }

    function flat(item,f) {
        for(var i in item.children) {
            var n = item.children[i]
            if(f)
                f(n)
        }
    }

    Component.onCompleted: {
        /*
//        Qak.debug('All @',root.tag) //¤qakdbg

        all(root,function(node){
            if(node.isLeaf) {
                var path = []
                backup(node,function(node){
                    path.unshift(node.tag)
                })
//                Qak.debug('Full path',path.join("/")) //¤qakdbg
            }
        })


//        Qak.debug('Flat @',root.tag) //¤qakdbg
        flat(root,function(node){
//            Qak.debug('@',node.tag) //¤qakdbg
        })


//        Qak.debug('Sequential @',root.tag) //¤qakdbg
        sequential(root,function(node,sequencer){
//            Qak.debug(node.tag, 'says', node.t) //¤qakdbg
        })
        */
    }
}
