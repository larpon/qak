import QtQuick 2.0

QtObject {
    id: log

    // TODO
    //property var filter

    property bool enabled: true
    property bool history: false

    property QtObject settings: QtObject {
        property string prefix: ""
        property string logPrefix: ""
        property string errorPrefix: "ERROR"
        property string warnPrefix: "WARNING"
        property string debugPrefix: "DEBUG"
        property string infoPrefix: "INFO"
        property string historyPrefix: "HISTORY"
    }

    property QtObject internal: QtObject {
        property var history: []
    }

    onEnabledChanged: {
        if(enabled) { // Empty history if any
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
        if(console && enabled) {
            // Convert arguments to a normal array
            var args = Array.prototype.slice.call(arguments);

            // Prepend context log prefix
            if(settings.logPrefix !== "")
                args.unshift(settings.logPrefix)

            // Prepend general log prefix
            if(settings.prefix !== "")
                args.unshift(settings.prefix)

            // Pass along arguments to console
            console.log.apply(console, args)
        } else if(history) // Record history
            internal.history.push(args)
    }

    function error() {
        if(console && enabled) {
            var args = Array.prototype.slice.call(arguments)

            if(settings.errorPrefix !== "")
                args.unshift(settings.errorPrefix)

            if(settings.prefix !== "")
                args.unshift(settings.prefix)

            console.error.apply(console, args)

        } else if(history)
            internal.history.push(args)
    }

    function debug() {
        if(console && enabled) {
            var args = Array.prototype.slice.call(arguments)

            if(settings.debugPrefix !== "")
                args.unshift(settings.debugPrefix)

            if(settings.prefix !== "")
                args.unshift(settings.prefix)

            console.debug.apply(console, args)

        } else if(history)
            internal.history.push(args)

    }

    function warn() {
        if(console && enabled) {
            var args = Array.prototype.slice.call(arguments)

            if(settings.warnPrefix !== "")
                args.unshift(settings.warnPrefix)

            if(settings.prefix !== "")
                args.unshift(settings.prefix)

            console.warn.apply(console, args)

        } else if(history)
            internal.history.push(args)
    }

    function info() {
        if(console && enabled) {
            var args = Array.prototype.slice.call(arguments)

            if(settings.infoPrefix !== "")
                args.unshift(settings.infoPrefix)

            if(settings.prefix !== "")
                args.unshift(settings.prefix)

            console.info.apply(console, args)

        } else if(history)
            internal.history.push(args)
    }

}
