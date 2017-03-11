import QtQuick 2.0

import Qak 1.0

// Adapted from https://github.com/developit/mitt
QtObject {

    property var topics: ({})

    signal subscribe(string topic, var handler)
    signal unsubscribe(string topic, var handler)
    signal publish(string topic, var event)

    // Get or create a named handler list
    function list(topic) {
        var t = topic.replace(/\/$/, "").toLowerCase()
        return topics[t] || (topics[t] = [])
    }

    function sub(topic, handler) {
//        Qak.debug(Qak.gid+'Events','::sub',topic) //¤qakdbg
        list(topic).push(handler)
        subscribe(topic, handler)
        return handler
    }

    function unsub(topic, handler) {
//        Qak.debug(Qak.gid+'Events','::unsub',topic) //¤qakdbg
        var e = list(topic),
        i = e.indexOf(handler)
        if (~i) e.splice(i, 1)
        unsubscribe(topic, handler)
    }

    function pub(topic, event) {
        var l = list('*').concat(list(topic))
        for(var k in l) {
//            Qak.debug(Qak.gid+'Events','::pub',topic) //¤qakdbg
            l[k](event)
        }
        publish(topic, event)
//        if(l.length <= 0) { Qak.debug(Qak.gid+'Events','::pub','no subscribers for',topic) } //¤qakdbg
    }

}
