import QtQuick 2.0

import Qak.Tools 1.0

QakObject {
    id: log

    // TODO filters

    property bool enabled: true
    property bool history: false

    property string gid: "¤#"
    property var groups: ({"*":true})
    property bool logGid: true

    property alias settings: settings
    QakObject {
        id: settings

        property alias output: settingsLogLevel
        QtObject {
            id: settingsLogLevel

            property bool log: true
            property bool info: true
            property bool warn: true
            property bool debug: true
            property bool error: true
        }

        property string prefix: ""
        property string logPrefix: ""
        property string errorPrefix: "ERROR"
        property string warnPrefix: "WARNING"
        property string debugPrefix: "DEBUG"
        property string infoPrefix: "INFO"
        property string historyPrefix: "HISTORY"
    }

    QtObject {
        id: internal
        property var history: []

        function logGroup(logArgsArray) {
            var s = logArgsArray[0]
            if(typeof s === "string") {
                if(Aid.startsWith(s,gid)) {
                    var groupName = s.replace(gid,"")
                    if(!logGid)
                        logArgsArray.shift()
                    else
                        logArgsArray[0] = groupName

                    if("*" in groups && groups["*"]) {
                        if((groupName in groups) && !groups[groupName])
                            return false
                        return true
                    }

                    if(!(groupName in groups))
                        return false
                    else {
                        if(!groups[groupName])
                            return false
                    }

                }
            }
            return true
        }
    }

    onEnabledChanged: {
        if(enabled) {
//            log.log(gid+"Log","groups",JSON.stringify(groups)) //¤qakdbg

            // Empty history if any
            var history = internal.history
            while(history.length > 0) {
                var args = history.shift()
                if(settings.historyPrefix !== "")
                    args.unshift(settings.historyPrefix)
                console.log.apply(console, args)
            }
        }
    }

    function log() {

        if(!settingsLogLevel.log) return

        // Convert arguments to a normal array
        var args = Array.prototype.slice.call(arguments);

        if(!internal.logGroup(args))
            return

        // Prepend context log prefix
        if(settings.logPrefix !== "")
            args.unshift(settings.logPrefix)

        // Prepend general log prefix
        if(settings.prefix !== "")
            args.unshift(settings.prefix)

        if(console && enabled) // Pass along arguments to console
            console.log.apply(console, args)
        else if(history) // Record history
            internal.history.push(args)
    }

    function error() {
        if(!settingsLogLevel.error) return

        var args = Array.prototype.slice.call(arguments)

        if(!internal.logGroup(args))
            return

        if(settings.errorPrefix !== "")
            args.unshift(settings.errorPrefix)

        if(settings.prefix !== "")
            args.unshift(settings.prefix)

        if(console && enabled)
            console.error.apply(console, args)
        else if(history)
            internal.history.push(args)

    }

    function debug() {
        if(!settingsLogLevel.debug) return

        var args = Array.prototype.slice.call(arguments)

        if(!internal.logGroup(args))
            return

        if(settings.debugPrefix !== "")
            args.unshift(settings.debugPrefix)

        if(settings.prefix !== "")
            args.unshift(settings.prefix)

        if(console && enabled)
            console.debug.apply(console, args)
        else if(history)
            internal.history.push(args)
    }

    function warn() {
        if(!settingsLogLevel.warn) return

        var args = Array.prototype.slice.call(arguments)

        if(!internal.logGroup(args))
            return

        if(settings.warnPrefix !== "")
            args.unshift(settings.warnPrefix)

        if(settings.prefix !== "")
            args.unshift(settings.prefix)

        if(console && enabled)
            console.warn.apply(console, args)
        else if(history)
            internal.history.push(args)
    }

    function info() {
        if(!settingsLogLevel.info) return

        var args = Array.prototype.slice.call(arguments)

        if(!internal.logGroup(args))
            return

        if(settings.infoPrefix !== "")
            args.unshift(settings.infoPrefix)

        if(settings.prefix !== "")
            args.unshift(settings.prefix)

        if(console && enabled)
            console.info.apply(console, args)
        else if(history)
            internal.history.push(args)
    }

}
