
if (typeof String.prototype.startsWith != 'function') {
  String.prototype.startsWith = function (str){
    return this.slice(0, str.length) == str;
  };
}

function get() {

    var incubator = {
        queue: {},
        async: true,
        debug: false,

        queueSize: function() {
            var size = 0, key, queue = this.queue;
            for(key in queue) {
                if (key in queue) size++;
            }
            return size;
        },

        now: function(input, parent, attributes, successCallback){
            var queueObject = this._toQueue(input, parent, attributes, successCallback)
            queueObject.go()
        },

        later: function(input, parent, attributes, successCallback){
            this._toQueue(input, parent, attributes, successCallback)
        },

        incubate: function(){
            var queue = this.queue, qid
            for(qid in queue) {
                queue[qid].go()
            }
        },

        _toQueue: function(input, parent, attributes, successCallback){

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
                if(type.startsWith("QQmlComponent"))
                    queueObject = this.fromComponent(input,parent,attributes,successCallback)
                else
                    throw 'Unknown input "'+input+'" of type "'+type+'"'
            } else {
                throw 'Unknown input "'+input+'" of type "'+type+'"'
            }

            return queueObject

        },

        fromComponent: function(component, parent, attributes, successCallback) {

            var incubatorInstance = this

            var qo = {}
            qo.id = incubatorInstance.queueSize()
            qo.component = component
            qo.incubator = undefined
            qo.parent = parent
            qo.attributes = attributes
            qo.onSuccess = successCallback || function(){}

            qo.componentStatusCallback = function(){
                if(incubatorInstance.debug) console.debug('componentStatusCallback',this.id);

                var that = this
                if(this.component.status === Component.Ready) {
                    var sync = Qt.Asynchronous
                    if(!incubatorInstance.async)
                        sync = Qt.Synchronous

                    this.incubator = this.component.incubateObject(this.parent, this.attributes, sync);

                    var incubatorStatusCallback = function(){
                        if(incubatorInstance.debug) console.debug('incubatorStatusCallback',that.id);

                        var status = that.incubator.status

                        if(Component && status === Component.Ready) {

                            that.onSuccess(that.incubator.object)
                            if(incubatorInstance.debug)console.info('incubated', that.id, that.incubator.object)
                                delete incubatorInstance.queue[that.id]
                            if(incubatorInstance.debug) console.info('new size',  incubatorInstance.queueSize())

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

            incubatorInstance.queue[qo.id] = qo

            return qo
        },
        wrapAsComponent: function(qml) {
            qml = qml.replace(/([A-Z]+\S+ *\{[^}]+\})/, "Component { $1 ")+'}'
            //console.log(qml)
            return qml
        }

    }
    return incubator
}
