/*
function findRoot(item) {
    if(item.objectName === "QakNode" && item.isRoot)
        return item
    else
        return findRoot(item.parent)
}
*/

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
        var children = object.children
        for(var i in children) {
            callback(children[i])
            loopChildren(children[i],callback)
        }
    }
}

function remap(oldValue, oldMin, oldMax, newMin, newMax) {
    // Linear conversion
    // NewValue = (((OldValue - OldMin) * (NewMax - NewMin)) / (OldMax - OldMin)) + NewMin
    return (((oldValue - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) + newMin;
}

function interpolate(x0, x1, alpha) {
    return (x0 * (1 - alpha) + alpha * x1)
}

//Normalizes any number to an arbitrary range
//by assuming the range wraps around when going below min or above max
// NOTE untested
function normalize( value, start, end )
{
    console.warn('Utility','using untested function normalize')
    var width       = end - start
    var offsetValue = value - start // value relative to 0

    return ( offsetValue - ( Math.floor( offsetValue / width ) * width ) ) + start
    // + start to reset back to start of original range
}

// NOTE untested
function normalize0to360(degrees) {
    console.warn('Utility','using untested function normalize0to360')
    degrees = degrees % 360
    if (degrees < 0)
        degrees += 360
    return degrees
}

/**
 * Returns a random number between min and max
 */
function randomRangeArbitary (min, max) {
    return Math.random() * (max - min) + min;
}

/**
 * Returns a random integer between min and max
 * Using Math.round() will give you a non-uniform distribution!
 */
function randomRangeInt (min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function endsWith (haystack, needle) {
    return needle === haystack.substr(0 - needle.length);
}

Object.size = function(obj) {
    var size = 0, key;
    for (key in obj) {
        if (key in obj) size++;
    }
    return size;
}

function clone(obj) {
    var copy;

    // Handle the 3 simple types, and null or undefined
    if (null == obj || "object" != typeof obj) return obj;

    // Handle Date
    if (obj instanceof Date) {
        copy = new Date();
        copy.setTime(obj.getTime());
        return copy;
    }

    // Handle Array
    if (obj instanceof Array) {
        copy = [];
        for (var i = 0, len = obj.length; i < len; i++) {
            copy[i] = clone(obj[i]);
        }
        return copy;
    }

    // Handle Object
    if (obj instanceof Object) {
        copy = {};
        for (var attr in obj) {
            if (obj.hasOwnProperty(attr)) copy[attr] = clone(obj[attr]);
        }
        return copy;
    }

    throw new Error("Unable to copy obj! Its type isn't supported.");
}

function dump(arr,level) {
    var dumped_text = "";
    if(!level) level = 0;

    //The padding given at the beginning of the line.
    var level_padding = "";
    for(var j=0;j<level+1;j++) level_padding += "    ";

    if(typeof(arr) == 'object') { //Array/Hashes/Objects
        for(var item in arr) {
            var value = arr[item];

            if(typeof(value) == 'object') { //If it is an array,
                dumped_text += level_padding + "'" + item + "' ...\n";
                dumped_text += dump(value,level+1);
            } else {
                dumped_text += level_padding + "'" + item + "' => \"" + value + "\"\n";
            }
        }
    } else { //Stings/Chars/Numbers etc.
        dumped_text = "===>"+arr+"<===("+typeof(arr)+")";
    }
    return dumped_text;
}

function randomProperty(obj) {
    var keys = Object.keys(obj)
    return obj[keys[ keys.length * Math.random() << 0]];
}

function randomFromArray(arr) {
    var key = Math.floor(Math.random() * arr.length);
    return arr[key];
}

function shuffle(array) {
  var currentIndex = array.length, temporaryValue, randomIndex ;

  // While there remain elements to shuffle...
  while (0 !== currentIndex) {

    // Pick a remaining element...
    randomIndex = Math.floor(Math.random() * currentIndex);
    currentIndex -= 1;

    // And swap it with the current element.
    temporaryValue = array[currentIndex];
    array[currentIndex] = array[randomIndex];
    array[randomIndex] = temporaryValue;
  }

  return array;
}

function extend(target, source) {
  target = target || {};
  for (var prop in source) {
    if (typeof source[prop] === 'object') {
      target[prop] = extend(target[prop], source[prop]);
    } else {
      target[prop] = source[prop];
    }
  }
  return target;
}

function isObject(o) {
    return o !== null && typeof o === 'object'
}

function isInteger(value) {
  var x
  if (isNaN(value))
    return false
  x = parseFloat(value)
  return (x | 0) === x
}
