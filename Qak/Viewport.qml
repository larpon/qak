import QtQuick 2.0

import Qak 1.0
import Qak.QtQuick 2.0

Item {
    id: viewport

    // bool to identify this object as a Qak Viewport
    readonly property bool qakViewport: true

    readonly property real aspectRatio: width/height
    //clip: true

    QtObject {
        id: internal
        property string fillModeString
//        onFillModeStringChanged: Qak.debug('Viewport',viewport,fillModeString) //¤qakdbg
    }

    readonly property alias assetMultiplier: localAssetSizeController.assetMultiplier
    AssetSizeController {
        id: localAssetSizeController
        offTargetPercent: ((viewport.widthDiff/viewport.width)*100)
    }

    property var container: parent
    readonly property real containerAspect: containerWidth/containerHeight
    onContainerAspectChanged: viewport.fix()
    readonly property real containerWidth: container.width
    onContainerWidthChanged: viewport.fix()
    readonly property real containerHeight: container.height
    onContainerHeightChanged: viewport.fix()

    property int fillMode: Image.PreserveAspectFit //Image.PreserveAspectCrop //Image.Stretch
    onFillModeChanged: viewport.fix()

    function toggleFillMode() {
        if(fillMode === Image.PreserveAspectFit)
           fillMode = Image.PreserveAspectCrop
        else if(fillMode === Image.Stretch)
           fillMode = Image.PreserveAspectFit
        else
           fillMode = Image.Stretch
    }

    readonly property real scaledWidth: viewport.width*activeScaler.xScale
    readonly property real scaledHeight: viewport.height*activeScaler.yScale

    readonly property int widthDiff: viewport.scaledWidth - viewport.width
    readonly property int heightDiff: viewport.scaledHeight - viewport.height

    readonly property Scale activeScaler: selectScaler(fillMode)

    transform: activeScaler

    Component.onCompleted: viewport.fix()

    Scale {
        id: aspectScale
        xScale: Math.min(container.width/viewport.width,container.height/viewport.height)
        yScale: xScale

    }

    Scale {
        id: aspectScaleCrop
        xScale: Math.max(container.width/viewport.width,container.height/viewport.height)
        yScale: xScale
        origin.x: (viewport.width*xScale)/container.width
        origin.y: (viewport.height*yScale)/container.height
    }

    Scale {
        id: stretchScale
        xScale: container.width/viewport.width
        yScale: container.height/viewport.height
    }

    function fix() {
        viewport.x = 0
        viewport.y = 0

        if(containerAspect == viewport.aspectRatio) {
            internal.fillModeString = "no boxes"
            return
        } else if(fillMode === Image.Stretch) {
            internal.fillModeString = "stretch"
            return
        } else if(fillMode === Image.PreserveAspectCrop) {
            viewport.x = (container.width-(viewport.width*aspectScaleCrop.xScale))/2
            viewport.y = (container.height-(viewport.height*aspectScaleCrop.yScale))/2
            internal.fillModeString = "preserve aspect crop"
            return
        }

        if(containerAspect < viewport.aspectRatio) {
            var ny = (container.height-(viewport.height*aspectScale.yScale))/2
            internal.fillModeString = "preserve aspect fit (horizontal boxes)"
            viewport.y = ny
            return
        }

        if(containerAspect > viewport.aspectRatio) {
            var nx = (container.width-(viewport.width*aspectScale.xScale))/2
            internal.fillModeString = "preserve aspect fit (vertical boxes)"
            viewport.x = nx
            return
        }
    }

    function selectScaler(fm) {
        return fm === Image.PreserveAspectFit ? aspectScale : fm === Image.PreserveAspectCrop ? aspectScaleCrop : stretchScale
    }
}
