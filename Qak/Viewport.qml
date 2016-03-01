import QtQuick 2.5

import Qak 1.0
import Qak.QtQuick 1.0

Item {
    id: viewport

    //clip: true

    property Item container: viewport.parent

    property int fillmode: Image.PreserveAspectFit //Image.PreserveAspectCrop //Image.Stretch

    onFillmodeChanged: {
        viewport.fix()
    }

    readonly property real scaledWidth: width*activeScaler.xScale
    readonly property real scaledHeight: height*activeScaler.yScale

    readonly property int widthDiff: viewport.scaledWidth - viewport.width
    readonly property int heightDiff: viewport.scaledWidth - viewport.width

    function toggleFillmode() {
        if(fillmode === Image.PreserveAspectFit)
           fillmode = Image.PreserveAspectCrop
        else if(fillmode === Image.Stretch)
           fillmode = Image.PreserveAspectFit
        else
           fillmode = Image.Stretch
    }

    property string fillmodeString: ""
    onFillmodeStringChanged: Qak.log('Viewport','Fillmode',fillmodeString)

    readonly property Scale activeScaler: selectScaler(fillmode)

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
            fillmodeString = "no boxes"
            return
        } else if(fillmode === Image.Stretch) {
            fillmodeString = "stretch"
            return
        } else if(fillmode === Image.PreserveAspectCrop) {
            viewport.x = (container.width-(viewport.width*aspectScaleCrop.xScale))/2
            viewport.y = (container.height-(viewport.height*aspectScaleCrop.yScale))/2
            fillmodeString = "preserve aspect crop"
            return
        }

        var nx = (container.width-(viewport.width*aspectScale.xScale))/2
        var ny = (container.height-(viewport.height*aspectScale.yScale))/2

        if(container.aspectRatio < viewport.aspectRatio) {
            fillmodeString = "preserve aspect fit (horizontal boxes)"
            viewport.y = ny
        }

        if(container.aspectRatio > viewport.aspectRatio) {
            fillmodeString = "preserve aspect fit (vertical boxes)"
            viewport.x = nx
        }
    }

    function selectScaler(fm) {
        return fm === Image.PreserveAspectFit ? aspectScale : fm === Image.PreserveAspectCrop ? aspectScaleCrop : stretchScale
    }

    /*
    function clamp(a,b,c) {
        return Math.max(b,Math.min(c,a))
    }

    function remap(oldValue, oldMin, oldMax, newMin, newMax) {
        // Linear conversion
        // NewValue = (((OldValue - OldMin) * (NewMax - NewMin)) / (OldMax - OldMin)) + NewMin
        return (((oldValue - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) + newMin;
    }
    */
}
