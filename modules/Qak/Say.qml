import QtQuick 2.5

Item {
    id: say
    property string text
    property Item visual

    property Item active: say
    property Item to: children.length > 0 ? children[0] : undefined
}
