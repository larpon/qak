#include "mouserotate_p.h"

MouseRotatePrivate::MouseRotatePrivate(QObject *parent) : QObject(parent)
{
    _normalized = 0;

    _flipping = false;
    _wrap = true;
    _continuous = false;

    _rotation = 0;
    _previousRotation = 0;

    recalculateNormalized();

    _rounds = 0;
}

qreal MouseRotatePrivate::getRotation() const
{
    return _rotation;
}

void MouseRotatePrivate::setRotation(qreal rotation)
{

    if(rotation != _rotation) {

        if(!_continuous) {
            setFlipping(false);
            if(rotation < 0) {
                setFlipping(true);
                _rounds--;
                emit roundsChanged();
            }
            if(rotation > 360) {
                setFlipping(true);
                _rounds++;
                emit roundsChanged();
            }
        }

        if(_wrap) {
            if(rotation < 0 || rotation > 360) {
                rotation = normalize(rotation,0,360);
                if(rotation == _rotation)
                    return;
            }
        } else if(_continuous) {
            // Not needed
        } else {
            if(rotation < 0)
                rotation = 0;
            if(rotation > 360)
                rotation = 360;
        }

        qreal previousRotation = _rotation;
        _rotation = rotation;
        emit this->rotated();
        recalculateNormalized();
        setPreviousRotation(previousRotation);
    }

}

qreal MouseRotatePrivate::getPreviousRotation() const
{
    return _previousRotation;
}

void MouseRotatePrivate::setPreviousRotation(const qreal &previousRotation)
{
    if(_previousRotation != previousRotation) {
        _previousRotation = previousRotation;
        emit previousRotationChanged();
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

bool MouseRotatePrivate::getContinuous() const
{
    return _continuous;
}

void MouseRotatePrivate::setContinuous(bool continuous)
{
    if(_continuous != continuous) {
        _continuous = continuous;
        if(_continuous)
            setWrap(false);
        emit continuousChanged();
    }
}

bool MouseRotatePrivate::getWrap() const
{
    return _wrap;
}

void MouseRotatePrivate::setWrap(bool wrap)
{
    if(_wrap != wrap) {
        _wrap = wrap;
        if(_wrap)
            setContinuous(false);
        emit wrapChanged();
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
    qreal normalized = ((_rotation - 0) / (360 - 0));
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
