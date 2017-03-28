import QtQuick 2.0

// NOTE "import Qak 1.0" and "import ".." " // <- will cause stall
import "."

pragma Singleton

// TODO make proper debug output and optimize
QtObject {
    id: incubator

    property var queue: ({})
    property bool asynchronous: true

    function queueSize() {
        var size = 0, key
        for(key in queue) {
            if (key in queue) size++
        }
        return size
    }

    function now(input, parent, attributes, successCallback) {
        var queueObject = _toQueue(input, parent, attributes, successCallback)
        queueObject.go()
    }

    function later(input, parent, attributes, successCallback){
        _toQueue(input, parent, attributes, successCallback)
    }

    function incubate() {
        for(var qid in queue) {
            if(queue[qid])
                queue[qid].go()
        }
    }

    function _toQueue(input, parent, attributes, successCallback) {

        //console.log('input is?',input.toString(),typeof input,Object.prototype.toString.call(input))

        var type = (typeof input)

        var queueObject

        if(type == 'string') {
            // Determine if raw qml string or url
            if(input.indexOf("Component") > -1) {
                var c = Qt.createQmlObject(input, parent, "incubator.js object_from_string")
                queueObject = this.fromComponent(c,parent,attributes,successCallback)
            } else {
                queueObject = this.fromComponent(Qt.createComponent(input),parent,attributes,successCallback)
            }
        } else if(type == 'object') {
            type = input.toString()
            if(Aid.startsWith(type,"QQmlComponent"))
                queueObject = this.fromComponent(input,parent,attributes,successCallback)
            else
                throw 'Unknown input "'+input+'" of type "'+type+'"'
        } else {
            throw 'Unknown input "'+input+'" of type "'+type+'"'
        }

        return queueObject

    }

    function fromComponent(component, parent, attributes, successCallback) {

        var incubatorInstance = this

        var qo = {}
        qo.id = incubator.queueSize()
        qo.component = component
        qo.incubator = undefined
        qo.parent = parent
        qo.attributes = attributes || {}
        qo.onSuccess = successCallback || function(){}

        qo.componentStatusCallback = function(){
            var that = this

//            console.debug('componentStatusCallback',this.id) //¤qakdbg

            if(this.component.status === Component.Ready) {
                var sync = Qt.Asynchronous
                if(!incubator.asynchronous)
                    sync = Qt.Synchronous

                this.incubator = this.component.incubateObject(this.parent, this.attributes, sync)

                var incubatorStatusCallback = function(){
//                    console.debug('incubatorStatusCallback',that.id) //¤qakdbg

                    var status = that.incubator.status

                    if(Component && status === Component.Ready) {

                        that.onSuccess(that.incubator.object)
//                      console.debug('incubated', that.id, that.incubator.object) //¤qakdbg
                        incubator.queue[that.id] = undefined
                        //delete incubator.queue[that.id]
//                      console.debug('new size',  incubatorInstance.queueSize()) //¤qakdbg
                    } else
                        throw 'incubation error '+status
                }

                if(this.incubator.status !== Component.Ready) {
                    this.incubator.onStatusChanged = incubatorStatusCallback
                } else {
                    incubatorStatusCallback()
                }

            } else if (this.component.status === Component.Error) {
                throw "Error loading component in callback " + this.component.errorString()
            } else {
                throw "Error unknown component status (in callback) " + this.component.status
            }
        }

        qo.go = function() {
            if(this.component.status === Component.Ready)
                this.componentStatusCallback()
            else {
                if(this.component.status === Component.Error) {
                    throw "Error loading component "+this.component.errorString()
                }
                if(this.component.statusChanged === undefined) {
                    throw "Error loading component "+this.component
                }

                this.component.statusChanged.connect(this.componentStatusCallback);
            }
        }

        incubator.queue[qo.id] = qo

        return qo
    }

    function wrapAsComponent(qml) {
        qml = qml.replace(/([A-Z]+\S+ *\{[^}]+\})/, "Component { $1 ")+'}'
        //console.log(qml)
        return qml
    }

}
