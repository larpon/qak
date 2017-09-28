#include "mouserotate_p.h"

MouseRotatePrivate::MouseRotatePrivate(QObject *parent) :
    QObject(parent),
    _rotation(0),
    _previousRotation(0),
    _normalized(0),
    _rounds(0),
    _flipping(false),
    _wrap(true),
    _continuous(false),
    _continuousInfinite(true),
    _continuousMin(0),
    _continuousMax(360),
    _min(0),
    _max(360)
{
    recalculateNormalized();
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
            if(rotation < _min) {
                setFlipping(true);
                _rounds--;
                emit roundsChanged();
            }
            if(rotation > _max) {
                setFlipping(true);
                _rounds++;
                emit roundsChanged();
            }
        }

        if(_wrap) {
            if(rotation < _min || rotation > _max) {
                rotation = normalize(rotation,_min,_max);
                if(rotation == _rotation)
                    return;
            }
        } else if(_continuous) {
            if(!_continuousInfinite) {
                if(rotation < _continuousMin) {
                    setFlipping(true);
                    _rounds--;
                    emit roundsChanged();
                }
                if(rotation > _continuousMax) {
                    setFlipping(true);
                    _rounds++;
                    emit roundsChanged();
                }

                rotation = normalize(rotation,_continuousMin,_continuousMax);
                if(rotation == _rotation)
                    return;
            }
        } else {
            if(rotation < _min)
                rotation = _min;
            if(rotation > _max)
                rotation = _max;
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

bool MouseRotatePrivate::getContinuousInfinite() const
{
    return _continuousInfinite;
}

void MouseRotatePrivate::setContinuousInfinite(bool continuousInfinite)
{
    if(_continuousInfinite != continuousInfinite) {
        _continuousInfinite = continuousInfinite;
        emit continuousInfiniteChanged();
    }
}

qreal MouseRotatePrivate::getContinuousMin() const
{
    return _continuousMin;
}

void MouseRotatePrivate::setContinuousMin(const qreal &continuousMin)
{
    if(_continuousMin != continuousMin) {
        _continuousMin = continuousMin;
        emit continuousMinChanged();
    }
}

qreal MouseRotatePrivate::getContinuousMax() const
{
    return _continuousMax;
}

void MouseRotatePrivate::setContinuousMax(const qreal &continuousMax)
{
    if(_continuousMax != continuousMax) {
        _continuousMax = continuousMax;
        emit continuousMaxChanged();
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
    qreal normalized = ((_rotation - _min) / (_max - _min));
    if(normalized != _normalized) {
        _normalized = normalized;
        emit normalizedChanged();
    }
}

qreal MouseRotatePrivate::getMin() const
{
    return _min;
}

void MouseRotatePrivate::setMin(const qreal &min)
{
    if(_min != min) {
        _min = min;
        emit minChanged();
    }
}

qreal MouseRotatePrivate::getMax() const
{
    return _max;
}

void MouseRotatePrivate::setMax(const qreal &max)
{
    if(_max != max) {
        _max = max;
        emit maxChanged();
    }

}

qreal MouseRotatePrivate::normalize(qreal value, qreal start, qreal end)
{
    qreal width = end - start;
    qreal offsetValue = value - start; // value relative to 0

    return ( offsetValue - ( qFloor( offsetValue / width ) * width ) ) + start;
}
