import QtQuick 2.5

import Qak 1.0
import Qak.QtQuick 1.0

Item {
    id: viewport

    //clip: true

    AssetSizeController {
        offTargetPercent: ((viewport.widthDiff/viewport.width)*100)
    }

    property Item container: parent

    property int fillMode: Image.PreserveAspectFit //Image.PreserveAspectCrop //Image.Stretch

    onFillModeChanged: {
        viewport.fix()
    }

    function toggleFillMode() {
        if(fillMode === Image.PreserveAspectFit)
           fillMode = Image.PreserveAspectCrop
        else if(fillMode === Image.Stretch)
           fillMode = Image.PreserveAspectFit
        else
           fillMode = Image.Stretch
    }

    readonly property real scaledWidth: width*activeScaler.xScale
    readonly property real scaledHeight: height*activeScaler.yScale

    readonly property int widthDiff: viewport.scaledWidth - viewport.width
    readonly property int heightDiff: viewport.scaledWidth - viewport.width

    property string fillModeString: ""
    onFillModeStringChanged: Qak.log('Viewport','FillMode',fillModeString)

    readonly property Scale activeScaler: selectScaler(fillMode)

    transform: activeScaler

    Component.onCompleted: {
        fix()
    }

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

    Connections {
        target: container

        onAspectRatioChanged: {
            viewport.fix()
        }
    }

    function fix() {
        viewport.x = 0
        viewport.y = 0

        if(container.aspectRatio == viewport.aspectRatio) {
            fillModeString = "no boxes"
            return
        } else if(fillMode === Image.Stretch) {
            fillModeString = "stretch"
            return
        } else if(fillMode === Image.PreserveAspectCrop) {
            viewport.x = (container.width-(viewport.width*aspectScaleCrop.xScale))/2
            viewport.y = (container.height-(viewport.height*aspectScaleCrop.yScale))/2
            fillModeString = "preserve aspect crop"
            return
        }

        var nx = (container.width-(viewport.width*aspectScale.xScale))/2
        var ny = (container.height-(viewport.height*aspectScale.yScale))/2

        if(container.aspectRatio < viewport.aspectRatio) {
            fillModeString = "preserve aspect fit (horizontal boxes)"
            viewport.y = ny
        }

        if(container.aspectRatio > viewport.aspectRatio) {
            fillModeString = "preserve aspect fit (vertical boxes)"
            viewport.x = nx
        }
    }

    function selectScaler(fm) {
        return fm === Image.PreserveAspectFit ? aspectScale : fm === Image.PreserveAspectCrop ? aspectScaleCrop : stretchScale
    }
}
