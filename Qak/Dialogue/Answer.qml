import QtQuick 2.0

import Qak 1.0

Say {
    id: ask

    property Item go: children.length === 1 ? children[0] : null

}
