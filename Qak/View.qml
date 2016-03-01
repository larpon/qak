import Qak 1.0
import Qak.QtQuick 1.0

// QML type to easen up the creation of application
Item {
    id: view

    readonly property alias viewportWidth: viewport.width
    readonly property alias viewportHeight: viewport.height

    // This is where children will go
    default property alias contents: canvas.data

    readonly property alias viewport: viewport
    readonly property alias canvas: canvas

    property real thresholdPercent: 25.0

    readonly property int assetMultiplier: (((Math.floor(((viewport.widthDiff/viewport.width)*100) / thresholdPercent) * thresholdPercent)+thresholdPercent)/thresholdPercent)
    onAssetMultiplierChanged: Qak.assetMultiplier = assetMultiplier
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


    Viewport {
        id: viewport

        /*
        Rectangle {
            anchors.fill: parent
            color: debug ? "grey" : "transparent"
            visible: color != "transparent"
        }
        */

        Item {
            id: canvas
            anchors.fill: parent
        }
    }

}
