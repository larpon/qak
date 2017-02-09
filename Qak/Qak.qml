import QtQuick 2.0

import Qak 1.0

pragma Singleton

QtObject {
    id : component

    property bool doDebug: false
    property bool paused: false

    onPausedChanged: debug('Qak',paused ? 'Paused' : 'Continued') //¤qakdbg

    property int assetMultiplier: 1
    onAssetMultiplierChanged: debug('Qak','asset multiplier',assetMultiplier) //¤qakdbg

    property Log logger: Log { enabled: doDebug }
    property QtObject platform: Qt.platform
    property QtObject resource: Resource { }

    readonly property string gid: logger.gid

    Component.onCompleted: {
        var os = Qt.platform.os
        platform.isDesktop = (
            os !== 'android' &&
            os !== 'ios' &&
            os !== 'blackberry' &&
            os !== 'winphone'
        )

        platform.isMobile = !platform.isDesktop

        logger.settings.prefix = "QAK"
    }

    // NOTE Hacky 'setTimeout' function based on Timer
    readonly property Item __qak: Item {
        id: qak
        Component { id: timerComponent; Timer {} }
        function setTimeout(callback, timeout)
        {
            var timer = timerComponent.createObject(qak)
            timer.interval = timeout || 0
            timer.triggered.connect(function()
            {
                timer.stop()
                timer.destroy()
                callback()
            })
            timer.start()
        }
    }

    function setTimeout(callback, timeout)
    {
        qak.setTimeout(callback,timeout)
    }

    function log() {
        logger.log.apply(logger, arguments)
    }

    function error() {
        logger.error.apply(logger, arguments)
    }

    function debug() {
        logger.debug.apply(logger, arguments)
    }

    function warn() {
        logger.warn.apply(logger, arguments)
    }

    function info() {
        logger.info.apply(logger, arguments)
    }

}
