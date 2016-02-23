import QtQuick 2.5

// Credits go to royconejo
// http://www.royconejo.com/bitmap-fonts-in-qt-quick-qml/
Row {
    property string text: ""
    Repeater {
        model: text.length
        // TODO
        Image {
            source: "bitmapfont/" + text.charCodeAt(index) + ".png"
        }
    }
}
