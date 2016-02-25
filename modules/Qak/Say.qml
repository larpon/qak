import QtQuick 2.5

import Qak 1.0

Item {
    id: say

    objectName: 'QakJob'

    property string tag: ""
    property var text
    property var extra

    property bool parallel: false

    property bool running: false

    readonly property Item root: findRoot(say)
    readonly property bool isRoot: (parent.objectName !== 'QakJob')
    readonly property bool isLeaf: (children.length <= 0)

    readonly property bool done: (jobQueue.length <= 0 && runQueue.length <= 0)

    property int delay: 1000

    property var jobQueue: []
    property var runQueue: []

    function touchJobQueue() {
        var t = jobQueue
        jobQueue = t
    }

    function touchRunQueue() {
        var t = runQueue
        runQueue = t
    }

    function addJob(job) {
        // TODO validation
        jobQueue.push(job)
        touchJobQueue()
        //Qak.db(tag,'Adding job',job)
    }

    function nextJob() {
        var job = jobQueue.shift()
        touchJobQueue()
        return job
    }

    function addRun(job) {
        runQueue.push(job)
        touchRunQueue()
        //Qak.db(tag,'Adding run',job)
    }

    function doneJob(job) {
        for(var i in runQueue) {
            var j = runQueue[i]
            if(j === job) {
                delete runQueue[i]
                touchRunQueue()
            }
        }
    }

    /*
    property string tag: ""
    property string text
    property Item visual

    property Item active: say
    property Item to: children.length > 0 ? children[0] : say

    readonly property Item conversation: findRoot(say)
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
            Qak.db('New conversation',active.text)
        }
    }
    */
    Component.onCompleted: {


        //Qak.db('Grand parent',conversation,'root?',root ? 'yes' : 'no','leaf?',leaf ? 'yes' : 'no','text',text)
        /*
        if(leaf && to !== undefined) {

        }
        */
        //goTo()
    }

    function findRoot(item) {
        if(item.objectName === 'QakJob' && item.isRoot)
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

    //onRunningChanged: Qak.db(tag,running ? 'starting' : 'stopping')

    onDoneChanged: if(done) Qak.db(tag,'done')

    onRunningChanged: {
        if(running) {
            // Detect jobs and fill queue
            for(var i in children) {
                // TODO validation
                addJob(children[i])
            }
        }

        if(running && say.text && say.text != "")
            Qak.db(tag+":",say.text)

        jobTimer.restart()
    }

    Timer {
        id: jobTimer
        repeat: parallel ? false : true
        interval: delay > 0 ? delay : 1
        //triggeredOnStart: true
        onTriggered: {
            //Qak.db(tag,'handling jobs')

            if(done) {
                say.running = false
                return
                //if(!root)
                //    say.parent.doneJob(say)
            }

            var job = nextJob()
            if(parallel) {
                while(job) {
                    //addRun(job)
                    job.running = true
                    job = nextJob()
                }
            } else {
                if(job) {
                    //addRun(job)
                    job.running = true
                }
            }


            //
            //active.controller = say
            //active.active = active
            //active.run = true
        }
    }
}
