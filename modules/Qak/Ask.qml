import QtQuick 2.5

import Qak 1.0

Item {
    id: say

    objectName: 'QakSay'

    property string text
    property Item visual

    property Item active: say
    property Item to: children.length > 0 ? children[0] : say

    property Item conversation: findRoot(say)
    readonly property bool root: (parent.objectName !== 'QakSay')
    readonly property bool leaf: (children.length <= 0)

    readonly property bool end: (say.leaf && say.to === say)

    readonly property bool doGoTo: (say.leaf && say.to !== say && say.to.conversation.active === say)

    property int wpm: 200
    property int delay: to ? (wpm/100)*1000 : 0

    function goTo() {
        //Qak.db('Say:',say.text)
        say.to.conversation.active = say.to
    }

    onActiveChanged: {
        if(active  && active !== say && active.objectName === 'QakSay' && active.root) {
            Qak.db('New conversation root',active.text)
            conversation = active
        }
    }

    Component.onCompleted: {
        //Qak.db('Grand parent',conversation,'root?',root ? 'yes' : 'no','leaf?',leaf ? 'yes' : 'no','text',text)
        /*
        if(leaf && to !== undefined) {

        }
        */
        //goTo()
    }

    function findRoot(item) {
        if(item.objectName === 'QakSay' && item.root)
            return item
        else
            return findRoot(item.parent)
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
        running: say.doGoTo
        interval: delay > 0 ? delay : 1
        onTriggered: {
            if(say.doGoTo) {
                say.goTo()
            }
            //say.go = false
        }
    }
}
