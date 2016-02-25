import QtQuick 2.5

import Qak 1.0

Item {
    id: say

    objectName: 'QakSay'

    property string text
    property Item visual

    property Item ref

    property bool question: false
    property bool run: false

    property Item active: say
    property Item to: children.length > 0 ? children[childIndex] : say
    property int childIndex: 0

    property Item conversation: findRoot(say)
    readonly property bool root: (parent.objectName !== 'QakSay')
    readonly property bool leaf: (children.length <= 0)

    readonly property bool last: (children.length-1 === childIndex)

    readonly property bool end: (say.leaf && say.to === say)

    readonly property bool doGoTo: (say.to !== say)

    property int wpm: 200
    property int delay: to ? (wpm/100)*1000 : 0

    function goTo() {
        //Qak.db('Say:',say.text)
        say.to.conversation.active = say.to
        if(childIndex+1 < children.length)
            childIndex++

        if(say.to.conversation.active.question) {
            Qak.db('Active is a question! Stopping conversation')
            conversation.run = false
        }
    }

    onLastChanged: {
        Qak.db('Last child!',say.to.text)
    }

    onActiveChanged: {

        if(active  && active !== say && active.objectName === 'QakSay' && active.root) {
            Qak.db('New conversation root',active.text)
            conversation = active
        }
    }

    Component.onCompleted: {

    }

    function findRoot(item) {
        if(item.objectName === 'QakSay' && item.root)
            return item
        else
            return findRoot(item.parent)
    }

    Timer {
        id: goToTimer
        running: say.doGoTo && run && !question
        repeat: true
        interval: delay > 0 ? delay : 1
        triggeredOnStart: true
        onTriggered: {
            if(say.doGoTo) {
                say.goTo()
            }

        }
    }
}
