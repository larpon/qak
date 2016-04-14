/*
function findRoot(item) {
    if(item.objectName === "QakNode" && item.isRoot)
        return item
    else
        return findRoot(item.parent)
}
*/

function remap(oldValue, oldMin, oldMax, newMin, newMax) {
    // Linear conversion
    // NewValue = (((OldValue - OldMin) * (NewMax - NewMin)) / (OldMax - OldMin)) + NewMin
    return (((oldValue - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) + newMin;
}

function interpolate(x0, x1, alpha) {
    return (x0 * (1 - alpha) + alpha * x1)
}

function randomIntFromInterval(min,max)
{
    return Math.floor(Math.random()*(max-min+1)+min)
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
