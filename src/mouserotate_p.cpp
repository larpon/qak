#include "mouserotate_p.h"

MouseRotatePrivate::MouseRotatePrivate(QObject *parent) : QObject(parent)
{
    _normalized = 0;

    _flipping = false;
    _wrapTicks = false;

    _tick = 0;
    _previousTick = 0;

    recalculateNormalized();

    _rounds = 0;
}

qreal MouseRotatePrivate::getTick() const
{
    return _tick;
}

void MouseRotatePrivate::setTick(qreal tick)
{
    if(tick != _tick) {

        if(_wrapTicks) {
            if(tick < 0 || tick > 360) {
                tick = normalize(tick,0,360);
                if(tick == _tick)
                    return;
            }
        } else {
            if(tick < 0)
                tick = 0;
            if(tick > 360)
                tick = 360;
        }

        qreal pTick = _tick;
        _tick = tick;
        emit this->tick();
        recalculateNormalized();
        setPreviousTick(pTick);
    }
}

qreal MouseRotatePrivate::getPreviousTick() const
{
    return _previousTick;
}

void MouseRotatePrivate::setPreviousTick(const qreal &previousTick)
{
    if(_previousTick != previousTick) {
        _previousTick = previousTick;
        emit previousTickChanged();
    }
}

qreal MouseRotatePrivate::getNormalized() const
{
    return _normalized;
}

int MouseRotatePrivate::getRounds() const
{
    return _rounds;
}

void MouseRotatePrivate::doTick()
{
    //qDebug() << "" << doTick();

    qreal tick = _tick;// + _advance;

    if(tick < 0) {
        setFlipping(true);
        tick = 360;
        setTick(tick);
        _rounds--;
        emit roundsChanged();
        return;
    }
    if(tick > 360) {
        setFlipping(true);
        tick = 0;
        setTick(tick);
        _rounds++;
        emit roundsChanged();
        return;
    }
    setFlipping(false);
    setTick(tick);

}

bool MouseRotatePrivate::getWrapTicks() const
{
    return _wrapTicks;
}

void MouseRotatePrivate::setWrapTicks(bool wrapTicks)
{
    if(_wrapTicks != wrapTicks) {
        _wrapTicks = wrapTicks;
        emit wrapTicksChanged();
    }
}

bool MouseRotatePrivate::isFlipping() const
{
    return _flipping;
}

void MouseRotatePrivate::setFlipping(bool flipping)
{
    if(_flipping != flipping) {
        _flipping = flipping;
        emit flippingChanged();
    }
}

void MouseRotatePrivate::recalculateNormalized()
{
    qreal normalized = ((_tick - 0) / (360 - 0));
    if(normalized != _normalized) {
        _normalized = normalized;
        emit normalizedChanged();
    }
}

qreal MouseRotatePrivate::normalize(qreal value, qreal start, qreal end)
{
    qreal width = end - start;
    qreal offsetValue = value - start; // value relative to 0

    return ( offsetValue - ( qFloor( offsetValue / width ) * width ) ) + start;
}
