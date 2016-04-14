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
