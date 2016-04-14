import QtQuick 2.0

import Qak 1.0

QtObject {

    property bool global: false
    property bool enabled: true
    property real offTargetPercent: 0
    property real thresholdPercent: 25.0

    readonly property int assetMultiplier: (((Math.floor(offTargetPercent / thresholdPercent) * thresholdPercent)+thresholdPercent)/thresholdPercent)
    onAssetMultiplierChanged: if(enabled && global) Qak.assetMultiplier = assetMultiplier

    // NOTE Keeping for reference calculations
    // This is the very base for calculating the suggested asset size
    /*
    function calculateMapStep() {
        if(!autoMapSource || ignore)
            return

        if(viewport.scaledWidth == 0 || core.targetWidth == 0)
            return

        // How many percent of target width are we off?
        // + = over
        // - = under
        var pct = (viewportWidthDiff/core.viewport.width)*100

        // Step in percent
        var percentStep = 25.0

        // Round to nearest step size
        // ... -50,-25,0,25,50 ...
        var step = Math.floor(pct / percentStep) * percentStep

        // Convert from percent step to integer step
        // ... -3,-2,-1,0,1,2,3 ...
        step = (step+percentStep)/percentStep

        // Round integer to nearest asset step size
        // ... -4,-2,0,2,4 ...
        step = Math.floor(step / assetStep) * assetStep

        mapStep = step
    }
    */
}
