import Qak.Private 1.0

pragma Singleton

AidPrivate {

    property var __math_abs: Math.abs
    property var __math_random: Math.random
    property var __math_floor: Math.floor
    property var __math_sqrt: Math.sqrt
    property var __math_pow: Math.pow
    property var __math_max: Math.max
    property var __math_round: Math.round
    property var __math_atan2: Math.atan2
    property real __pi: Math.PI

    function loopData(object,callback) {
        if(object !== undefined && object !== null) {
            if('data' in object) {
                var data = object.data
                for(var i in data) {
                    callback(data[i])
                    loopData(data[i],callback)
                }
            }
        }
    }

    function loopChildren(object,callback) {
        if(object !== undefined && object !== null) {
            var children = object.children, i
            for(i in children) {
                callback(children[i])
                loopChildren(children[i],callback)
            }
        }
    }

    // These will loop Loader types as well as 'normal' QML objects
    function loopDataDeep(object,callback) {
        if('item' in object && qtypeof(object) === "QQmlTimer")
            object = object.item
        if(object !== undefined && object !== null) {
            if('data' in object) {
                var data = object.data
                for(var i in data) {
                    callback(data[i])
                    loopDataDeep(data[i],callback)
                }
            }
        }
    }

    function loopChildrenDeep(object,callback) {
        if('item' in object && qtypeof(object) === "QQmlTimer")
            object = object.item
        if(object !== undefined && object !== null) {
            var children = object.children, i
            for(i in children) {
                callback(children[i])
                loopChildrenDeep(children[i],callback)
            }
        }
    }

    function loopParent(object,callback) {
        if(object !== undefined && object !== null) {
            var parent = object.parent
            if(parent) {
                callback(parent)
                if(parent.parent)
                    loopParent(parent.parent,callback)
            }
        }
    }

    function chance(percent) {
        return ((__math_random() * 100) < percent)
    }

    /* Moved to C++ implementation
    function interpolate(x0, x1, alpha) {
        return (x0 * (1 - alpha) + alpha * x1)
    }

    function lerp(x0, x1, alpha) {
        return interpolate(x0,x1,alpha)
    }
    */

    function roundTo(n, digits) {
        if (digits === undefined)
            digits = 0

        var multiplicator = __math_pow(10, digits)
        n = parseFloat((n * multiplicator).toFixed(11))
        return +((Math.round(n) / multiplicator).toFixed(digits))
    }

    //Normalizes any number to an arbitrary range
    //by assuming the range wraps around when going below min or above max
    function normalize( value, start, end )
    {
        var width       = end - start,
            offsetValue = value - start // value relative to 0

        return ( offsetValue - ( __math_floor( offsetValue / width ) * width ) ) + start
        // + start to reset back to start of original range
    }

    function toDegrees(angle) {
        return angle * (180 / __pi)
    }

    function toRadians(degree) {
        return degree * (__pi / 180)
    }

    function normalize0to360(degrees) {
        degrees = degrees % 360
        if (degrees < 0)
            degrees += 360
        return degrees
    }

    // Oscillate e.g. "wave" or "ping-pong" between min and max value
    // Integers only
    function oscillate(value, min, max) {
        var range = max - min
        return min + __math_abs(((value + range) % (range * 2)) - range)
    }

    /* Moved to C++ implementation
    function undefinedOrNull(value) {
        return (value === undefined || value === null)
    }*/

    function isBetween(value,min,max) {
        return value >= min && value <= max
    }

    /**
     * Returns a random number between min and max
     */
    function randomRangeArbitary(min, max) {
        return __math_random() * (max - min) + min
    }

    /**
     * Returns a random integer between min and max
     * Using Math.round() will give you a non-uniform distribution!
     */
    function randomRangeInt(min, max) {
        return __math_floor(__math_random() * (max - min + 1)) + min
    }

    function hasOneOf(haystack, arr) {
        if(isArray(haystack) && isArray(arr)) {
            return arr.some(function (v) {
                return haystack.indexOf(v) >= 0
            })
        }
        return false
    }

    function hasAllOf(haystack, needle) {
        if(isArray(haystack) && isArray(arr)) {
            for(var i = 0; i < needle.length; i++){
                if(haystack.indexOf(needle[i]) === -1)
                    return false
            }
            return true
        }
        return false
    }

    function contains(haystack, needle) {
        return !undefinedOrNull(haystack) && haystack.indexOf(needle) !== -1;
    }

    function startsWith(haystack, needle) {
        return !undefinedOrNull(haystack) && haystack.lastIndexOf(needle, 0) === 0
    }

    function endsWith(haystack, needle) {
        if(!isString(haystack))
            return false
        return needle === haystack.substr(0 - needle.length)
    }

    function objectSize(obj) {
        if(isObject(obj)) {
            var size = 0, key
            for (key in obj) {
                if (key in obj) size++
            }
            return size
        }
        return 0
    }

    function toArray(obj) {
        return Object.keys(obj).map(function(key) { return obj[key] })
    }

    function clean(v,cl) {
        cl = cl || undefined
        // TODO enable to use cl as a value you want to clean out
        // so if undefined clean falsy values else clean for user specified
        if(isArray(v)) {
            var newArray = []
            for (var i = 0; i < v.length; i++) {
                if(v[i] && v[i] !== cl)
                    newArray.push(v[i])
            }
            return newArray
        }

        return v
    }

    function equals(i1,i2) {
        // TODO support other types
        // Compare two arrays
        if(isArray(i1) && isArray(i2)) {
            // From https://stackoverflow.com/questions/7837456/how-to-compare-arrays-in-javascript
            // if the other array is a falsy value, return
            if (!i2)
                return false

            // compare lengths - can save a lot of time
            if (i1.length !== i2.length)
                return false;

            for (var i = 0, l=i1.length; i < l; i++) {
                // Check if we have nested arrays
                if (isArray(i1[i]) && isArray(i2[i])) {
                    // recurse into the nested arrays
                    if (!equals(i1[i],i2[i]))
                        return false
                }
                else if (i1[i] !== i2[i]) {
                    // Warning - two different object instances will never be equal: {x:20} != {x:20}
                    return false
                }
            }
            return true
        }

        if(isObject(i1) && isObject(i2))
            return JSON.stringify(i1) === JSON.stringify(i2)

        return false
    }

    function clone(obj) {
        var copy

        // Handle the 3 simple types, and null or undefined
        if (null == obj || "object" != typeof obj) return obj

        // Handle Date
        if (obj instanceof Date) {
            copy = new Date()
            copy.setTime(obj.getTime())
            return copy
        }

        // Handle Array
        if (obj instanceof Array) {
            copy = []
            for (var i = 0, len = obj.length; i < len; i++) {
                copy[i] = clone(obj[i])
            }
            return copy
        }

        // Handle Object
        if (obj instanceof Object) {
            copy = {}
            for (var attr in obj) {
                if (obj.hasOwnProperty(attr)) copy[attr] = clone(obj[attr])
            }
            return copy
        }

        throw new Error("Unable to copy obj! Its type isn't supported.")
    }

    function dump(arr,level,filters) {
        filters = filters || []
        var dumped_text = ""
        if(!level) level = 0

        //The padding given at the beginning of the line.
        var level_padding = ""
        for(var j=0;j<level+1;j++) level_padding += "    "

        if(typeof(arr) == 'object') { //Array/Hashes/Objects
            for(var item in arr) {
                var value = arr[item]

                var skip = false
                for(var fi in filters) {
                    if(!filters[fi](item,value)) {
                        skip = true
                        break
                    }
                }
                if(skip) continue

                if(typeof(value) == 'object') { //If it is an array,
                    dumped_text += level_padding + "'" + item + "' ...\n"
                    dumped_text += dump(value,level+1)
                } else {
                    dumped_text += level_padding + "'" + item + "' => \"" + value + "\" "+'('+typeof value+')'+"\n"
                }
            }
        } else { //Stings/Chars/Numbers etc.
            dumped_text = "===>"+arr+"<===("+typeof(arr)+")"
        }
        return dumped_text
    }

    function inArray(needle, haystack) {
        if(!isArray(haystack))
            return false
        return (haystack.indexOf(needle) > -1)
    }

    function randomProperty(obj) {
        var keys = Object.keys(obj)
        return obj[keys[ keys.length * __math_random() << 0]]
    }

    function randomFromArray(arr) {
        var key = __math_floor(__math_random() * arr.length)
        return arr[key]
    }

    function shuffle(array) {
      var currentIndex = array.length, temporaryValue, randomIndex

      // While there remain elements to shuffle...
      while (0 !== currentIndex) {

        // Pick a remaining element...
        randomIndex = __math_floor(__math_random() * currentIndex)
        currentIndex -= 1

        // And swap it with the current element.
        temporaryValue = array[currentIndex]
        array[currentIndex] = array[randomIndex]
        array[randomIndex] = temporaryValue
      }

      return array
    }

    function extend(target, source, maxLevel) {
        target = target || {}

        for (var prop in source) {
            if (typeof source[prop] === 'object') {
                if(isInteger(maxLevel)) {
                    if(maxLevel > 1)
                        target[prop] = extend(target[prop], source[prop],maxLevel--)
                    else if(maxLevel === 1)
                        target[prop] = source[prop]
                } else
                    target[prop] = extend(target[prop], source[prop])
            } else {
                target[prop] = source[prop]
            }
        }
        return target
    }

    function unique(array) {
        var a = array.concat()
        for(var i=0; i<a.length; ++i) {
            for(var j=i+1; j<a.length; ++j) {
                if(a[i] === a[j])
                   a.splice(j--, 1)
            }
        }
        return a
    }

    function pad(number, digits, padChar) {
        padChar = padChar || 0
        return new Array(__math_max(digits + 1 - String(number).length + 1, 0)).join(padChar) + number
    }

    function readDuration(text, wpm) {
        wpm = wpm || 160
        var wc = text.split(' ').length
        if(wc <= 2) wc = 3
        return __math_round((wc/wpm)*60*1000)
    }

    function countPad(str, padChar) {
        padChar = padChar || "0"
        var count = 0
        for (var i = 0, len = str.length; i < len; i++) {
            if(str[i] === padChar)
                count++
            else
                break
        }
        // NOTE fixes a string with all zeroes e.g.: '0000'
        if(count === str.length)
            count--
        return count
    }

    // Greatest Common Divisor
    function gcd (a, b) {
        return (b === 0) ? a : gcd (b, a%b)
    }

    function distance(x1,y1,x2,y2) {
        if((isObject(x1) && 'x' in x1 && 'y' in x1) && (isObject(y1) && 'x' in y1 && 'y' in y1))
            return __math_sqrt( (x1.x-y1.x)*(x1.x-y1.x) + (x1.y-y1.y)*(x1.y-y1.y) )
        else
            return __math_sqrt( (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2) )
    }

    function manhattanDistance(x1,y1,x2,y2) {
        if((isObject(x1) && 'x' in x1 && 'y' in x1) && (isObject(y1) && 'x' in y1 && 'y' in y1))
            return __math_abs(x1.x-y1.x) + __math_abs(x1.y-y1.y)
        else
            return __math_abs(x1-x2) + __math_abs(y1-y2)
    }

    function angleBetween(x1,y1,x2,y2) {
        return toDegrees(__math_atan2(y1 - y2,x1 - x2))
    }

    /* Moved to C++ implementation
    function isObject(o) {
        return !undefinedOrNull(o) && typeof o === 'object' && !isArray(o)
    }
    */

    function hasStringProperty(o,prop) {
        return hasProperty(o,prop) && isString(o[prop])
    }

    /*
    function hasProperty(o,prop) {
        var resNative = tmpHasProperty(o, prop)
        var resJS = isObject(o) && (prop in o)
        if(resNative !== resNative)
            console.error('Aid::hasProperty','native differ from JS result on',o,prop) //¤
        return isObject(o) && (prop in o)
    }*/

    function hasPropertyWithValue(o,prop,value) {
        return hasProperty(o,prop) && o[prop] === value
    }

    function isInteger(value) {
      var x
      if (isNaN(value))
        return false
      x = parseFloat(value)
      return (x | 0) === x
    }

    function isFloat(value) {
        return !isNaN(parseFloat(value))
    }

    function isNumeric(value){
        return !isNaN(value)
    }

    function isFunction(v) {
        return (typeof v === "function")
    }

    /* Moved to C++ implementaion
    function isArray(a) {
        return (a instanceof Array)
    }
    */

    /* Moved to C++ implementaion
    function isString(v) {
        return (typeof v === 'string' || v instanceof String)
    }*/

    function isEmpty(obj) {

        // null and undefined are "empty"
        if (obj === null) return true
        if (obj === undefined) return true

        if (isString(obj)) return (obj === "")

        // Assume if it has a length property with a non-zero value
        // that that property is correct.
        if ('length' in obj && obj.length > 0)    return false
        if ('length' in obj && obj.length === 0)  return true

        // If it isn't an object at this point
        // it is empty, but it can't be anything *but* empty
        // Is it empty?  Depends on your application.
        if (typeof obj !== "object") return true

        // Otherwise, does it have any properties of its own?
        // Note that this doesn't handle
        // toString and valueOf enumeration bugs in IE < 9
        for (var key in obj) {
            if (hasOwnProperty.call(obj, key)) return false
        }

        return true
    }

    // WARNING There is currently no official Qt 5.6 way of getting the QML type of an object as a string - so this might break someday!
    // Further more this won't take QML inheritance into account :(
    function qtypeof(object) {

        if(object === null)
            return 'null'
        if(object === undefined)
            return 'undefined'

        var type = typeof object

        if(type === "object") {
            if('toString' in object && isFunction(object.toString)) {
                type = object.toString()
                //if(type.match(/.*_QMLTYPE_.*/i)) {
                    type = type.replace(/_QMLTYPE_.*/i,'')
                //} else if(type.match(/QQuick.*/i)) {
                    type = type.replace(/\(0x.*\)$/i,'')
                    type = type.replace(/_QML_\d+$/i,'')
                //}
                type = type.replace(/QPoint.*/i,'QPoint')
                type = type.replace(/QRect.*/i,'QRect')
            }
        }
        return type
    }

    function basename(path) {
        return path.split(/[\\/]/).pop()
    }

    function truncate(string, maxLength){
       if (string.length > maxLength)
          return string.substring(0,maxLength)+'...'
       else
          return string
    }



    // TODO optimize and test
    // Dijkstra's algorithm
    // https://github.com/andrewhayward/dijkstra
    // https://raw.githubusercontent.com/andrewhayward/dijkstra/master/graph.js
    // MIT Licence: https://github.com/andrewhayward/dijkstra/blob/master/LICENSE
    // Node input format:
    //  nodes = {
    //      'name1': {
    //          'name2': <weight>,
    //          'name3': <weight>
    //      },
    //      'name2': {
    //          'name1': <weight>,
    //          'name3': <weight>
    //      },
    //      'name3': {
    //          'name1': <weight>,
    //          'name2': <weight>,
    //          'name4': <weight>
    //      },
    //      'name4': {
    //          'name1': <weight>,
    //          'name2': <weight>
    //      }
    //  }
    //
    //  Example call: findShortestPath(nodes,'name1','name4')
    //  Ouput: [ 'name1', 'name3', 'name4' ]
    function findShortestPath(nodes,from,to) {

        var extractKeys = function (obj) {
            var keys = [], key
            for (key in obj) {
                //Object.prototype.hasOwnProperty.call(obj,key) && keys.push(key)
                if(Object.prototype.hasOwnProperty.call(obj,key))
                    keys.push(key)
            }
            return keys
        }

        var sorter = function (a, b) {
            return parseFloat (a) - parseFloat (b)
        }

        var findPaths = function (map, start, end, infinity) {
            infinity = infinity || Infinity

            var costs = {},
                open = {'0': [start]},
                predecessors = {},
                keys

            var addToOpen = function (cost, vertex) {
                var key = "" + cost
                if (!open[key]) open[key] = []
                open[key].push(vertex)
            }

            costs[start] = 0

            while (open) {
                if(!(keys = extractKeys(open)).length) break

                keys.sort(sorter)

                var key = keys[0],
                    bucket = open[key],
                    node = bucket.shift(),
                    currentCost = parseFloat(key),
                    adjacentNodes = map[node] || {}

                if (!bucket.length) delete open[key]

                for (var vertex in adjacentNodes) {
                    if (Object.prototype.hasOwnProperty.call(adjacentNodes, vertex)) {
                        var cost = adjacentNodes[vertex],
                            totalCost = cost + currentCost,
                            vertexCost = costs[vertex]

                        if ((vertexCost === undefined) || (vertexCost > totalCost)) {
                            costs[vertex] = totalCost
                            addToOpen(totalCost, vertex)
                            predecessors[vertex] = node
                        }
                    }
                }
            }

            if (costs[end] === undefined) {
                return null
            } else {
                return predecessors
            }

        }

        var extractShortest = function (predecessors, end) {
            var nodes = [],
                u = end

            while (u) {
                nodes.push(u)
                u = predecessors[u]
            }

            nodes.reverse()
            return nodes
        }

        var findShortestPath = function (map, nodes) {
            var start = nodes.shift(),
                end,
                predecessors,
                path = [],
                shortest

            while (nodes.length) {
                end = nodes.shift()
                predecessors = findPaths(map, start, end)

                if (predecessors) {
                    shortest = extractShortest(predecessors, end)
                    if (nodes.length) {
                        path.push.apply(path, shortest.slice(0, -1))
                    } else {
                        return path.concat(shortest)
                    }
                } else {
                    return null
                }

                start = end
            }
        }

        var toArray = function (list, offset) {
            try {
                return Array.prototype.slice.call(list, offset)
            } catch (e) {
                var a = []
                for (var i = offset || 0, l = list.length; i < l; ++i) {
                    a.push(list[i])
                }
                return a
            }
        }

        var Graph = function (map) {
            this.map = map
        }

        Graph.prototype.findShortestPath = function (start, end) {
            if (Object.prototype.toString.call(start) === '[object Array]') {
                return findShortestPath(this.map, start)
            } else if (arguments.length === 2) {
                return findShortestPath(this.map, [start, end])
            } else {
                return findShortestPath(this.map, toArray(arguments))
            }
        }

        Graph.findShortestPath = function (map, start, end) {
            if (Object.prototype.toString.call(start) === '[object Array]') {
                return findShortestPath(map, start)
            } else if (arguments.length === 3) {
                return findShortestPath(map, [start, end])
            } else {
                return findShortestPath(map, toArray(arguments, 1))
            }
        }

        return Graph.findShortestPath(nodes,from,to)

    }


}
