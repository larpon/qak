import QtQuick 2.5

import Qak 1.0

Item {
    id: say

    objectName: 'QakSay'

    property string text
    property Item visual

    property Item active: say
    property Item to: children.length > 0 ? children[0] : undefined

    readonly property Item conversation: findGrandParent(say)
    readonly property bool root: (parent.objectName !== 'QakSay')
    readonly property bool leaf: (children.length <= 0)

    readonly property bool canGoTo: (say.leaf && say.to !== undefined && say === conversation.active && say.to.conversation.active === say)

    property int wpm: 200
    property int delay: to ? (wpm/100)*1000 : 0



    Component.onCompleted: {
        //Qak.db('Grand parent',conversation,'root?',root ? 'yes' : 'no','leaf?',leaf ? 'yes' : 'no','text',text)
        /*
        if(leaf && to !== undefined) {

        }
        */
        //goTo()
    }

    function findGrandParent(item) {
        if(item.objectName === 'QakSay' && item.parent.objectName !== 'QakSay')
            return item
        else
            return findGrandParent(item.parent)
    }

    /*
    function goTo() {
        if {
            goToTimer.restart()
        }
    }
    */

    /*
    Connections {
        target: conversation
        onActiveChanged: {
            if(say.leaf && say.to !== undefined && say !== conversation.active)
                goToTimer.running = true
        }
    }
    */

    Timer {
        id: goToTimer
        running: say.canGoTo
        interval: delay > 0 ? delay : 1
        onTriggered: {
            if(say.canGoTo)
                say.to.conversation.active = say.to
        }
    }
}
