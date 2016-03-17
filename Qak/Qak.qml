import QtQuick 2.0

import Qak 1.0

pragma Singleton

Item {
    id : component

    property bool debug: false
    property bool pause: false

    onPauseChanged: info(pause ? 'Paused' : 'Continued')

    property string logPrefix: "QAK"

    property int assetMultiplier: 1
    onAssetMultiplierChanged: db('Asset multiplier',assetMultiplier)

    property QtObject platform: Qt.platform
    property QtObject resource: Resource { }

    Component.onCompleted: {
        var os = Qt.platform.os
        platform.isDesktop = (
            os !== 'android' &&
            os !== 'ios' &&
            os !== 'blackberry' &&
            os !== 'winphone'
        )

        platform.isMobile = !platform.isDesktop
    }

    function log() {
        //log.history=log.history||[]
        //log.history.push(arguments)
        if(console) {
            // 1. Convert args to a normal array
            var args = Array.prototype.slice.call(arguments);

            // 2. Prepend log prefix log string
            if(logPrefix != "")
                args.unshift(logPrefix);

            // 3. Pass along arguments to console.log
            console.log.apply(console, args);
            //console.log('QAK',Array.prototype.slice.call(arguments))
        }
    }

    function error() {
        //log.history=log.history||[]
        //log.history.push(arguments)
        if(console) {
            var args = Array.prototype.slice.call(arguments)
            args.unshift("QAK ERROR")
            console.error.apply(console, args)
        }
    }

    function db() {
        //db.history=db.history||[]
        //db.history.push(arguments)
        if(console && debug) {
            var args = Array.prototype.slice.call(arguments)
            args.unshift("QAK DEBUG")
            console.debug.apply(console, args)
        }
    }

    function warn() {
        //db.history=db.history||[]
        //db.history.push(arguments)
        if(console) {
            var args = Array.prototype.slice.call(arguments)
            args.unshift("QAK WARNING")
            console.warn.apply(console, args)
        }
    }

    function info() {
        //log.history=log.history||[]
        //log.history.push(arguments)
        if(console) {
            var args = Array.prototype.slice.call(arguments)
            args.unshift("QAK INFO")
            console.info.apply(console, args)
        }
    }

}
