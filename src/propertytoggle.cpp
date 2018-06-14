#include "propertytoggle.h"


PropertyToggle::PropertyToggle(QQuickItem* parent) : QQuickItem(parent)
{
    _enabled = true;
    _toggle = 0;
    _lastToggled = 0;
    _children = childItems();
    setFlag(ItemHasContents);
}

void PropertyToggle::componentComplete()
{
    // NOTE it's important to call the base class method
    QQuickItem::componentComplete();

    _children = childItems();
    if(_children.size() > 0) {
        foreach(QQuickItem *qi, _children) {
            qi->setProperty(_property.toLatin1().constData(),_offValue);
        }
        if(_toggle == 1) {
            ensureProperty();
        } else
            setToggle(1);
    }

}

void PropertyToggle::itemChange(QQuickItem::ItemChange change, const QQuickItem::ItemChangeData &value)
{
    if(change == QQuickItem::ItemChildAddedChange || QQuickItem::ItemChildRemovedChange) {
        _children = childItems();
        foreach(QQuickItem *qi, _children) {
            qi->setProperty(_property.toLatin1().constData(),_offValue);
        }
        ensureProperty();
    }
    QQuickItem::itemChange(change, value);
}

bool PropertyToggle::enabled() const
{
    return _enabled;
}

void PropertyToggle::setEnabled(bool enabled)
{
    if(_enabled != enabled) {
        _enabled = enabled;
        emit enabledChanged();
    }
}

QString PropertyToggle::property() const
{
    return _property;
}

void PropertyToggle::setProperty(const QString &property)
{
    if(_property != property) {
        _property = property;
        emit propertyChanged();
    }
}

QVariant PropertyToggle::onValue() const
{
    return _onValue;
}

void PropertyToggle::setOnValue(const QVariant &onValue)
{
    if(_onValue != onValue) {
        _onValue = onValue;
        emit onChanged();
    }
}

QVariant PropertyToggle::offValue() const
{
    return _offValue;
}

void PropertyToggle::setOffValue(const QVariant &offValue)
{
    if(_offValue != offValue) {
        _offValue = offValue;
        emit offChanged();
    }
}

int PropertyToggle::toggle() const
{
    return _toggle;
}

void PropertyToggle::setToggle(int toggle)
{
    if(toggle < 1)
        toggle = 1;
    if(toggle > _children.size())
        toggle = _children.size();

    if(_toggle != toggle) {
        _toggle = toggle;
        ensureProperty();
        emit toggleChanged();
    }
}

void PropertyToggle::clear()
{
    if(_lastToggled)
        _lastToggled = 0;
    _children.clear();
}

void PropertyToggle::ensureProperty()
{
    if(!_enabled || _toggle-1 < 0 || _toggle > _children.size()) {
        //qDebug() << this << "::ensureProperty" << _toggle << _toggle-1 << "< 0 ||" << _toggle << ">" << _children.size();
        return;
    }
    if(_lastToggled != 0) {
        //qDebug() << this << "::ensureProperty" << "_lastToggled" << "!= 0" << "setting" << _property.toLatin1().constData() << "to (offValue)" << _offValue;
        _lastToggled->setProperty(_property.toLatin1().constData(),_offValue);
    }
    QQuickItem *qi = _children.at(_toggle-1);
    //qDebug() << this << "::ensureProperty" << "setting" << _property.toLatin1().constData() << "to (onValue)" << _onValue;
    qi->setProperty(_property.toLatin1().constData(),_onValue);
    _lastToggled = qi;
}

void PropertyToggle::next()
{
    int n = _toggle+1;
    if(n > _children.size())
        n = 1;
    setToggle(n);
}

void PropertyToggle::previous()
{
    int n = _toggle-1;
    if(n < 1)
        n = _children.size();
    setToggle(n);
}
