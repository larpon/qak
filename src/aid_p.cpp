#include "aid_p.h"

AidPrivate::AidPrivate(QObject *parent) : QObject(parent)
{

}

qreal AidPrivate::remap(qreal oldValue, qreal oldMin, qreal oldMax, qreal newMin, qreal newMax)
{
    if(oldMin == newMin && oldMax == newMax)
        return oldValue;
    // Linear conversion
    // NewValue = (((OldValue - OldMin) * (NewMax - NewMin)) / (OldMax - OldMin)) + NewMin
    return (((oldValue - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) + newMin;
}
