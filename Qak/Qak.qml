import QtQuick 2.0

import Qak 1.0

pragma Singleton

Item {
    id : component

    property bool doDebug: false
    property bool keepDebugHistory: false
    property bool paused: false

    onPausedChanged: info('Qak',paused ? 'Paused' : 'Continued')

    property int assetMultiplier: 1
    onAssetMultiplierChanged: debug('Qak','asset multiplier',assetMultiplier)

    property QtObject logger: Log { enabled: doDebug; history: keepDebugHistory }
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

        logger.settings.prefix = "QAK"
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
