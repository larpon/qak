#include "propertytoggle.h"


PropertyToggle::PropertyToggle(QQuickItem* parent) : QQuickItem(parent)
{
    _toggle = 0;
    _lastToggled = 0;
    //connect(this, &ItemToggle::widthChanged, this, &ItemToggle::doUpdate);
    //connect(this, &ItemToggle::heightChanged, this, &ItemToggle::doUpdate);
    setFlag(ItemHasContents);
}


void PropertyToggle::componentComplete()
{
    // NOTE it's important to call the base class method
    QQuickItem::componentComplete();

    _children = childItems();
    foreach(QQuickItem *qi, _children) {
        qi->setProperty(_property.toLatin1().constData(),_offValue);
    }
    setToggle(1);


}

void PropertyToggle::itemChange(QQuickItem::ItemChange change, const QQuickItem::ItemChangeData &value)
{
    if(change == QQuickItem::ItemChildAddedChange || QQuickItem::ItemChildRemovedChange)
        _children = childItems();
    QQuickItem::itemChange(change, value);
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
        if(_lastToggled != 0)
            _lastToggled->setProperty(_property.toLatin1().constData(),_offValue);
        QQuickItem *qi = _children.at(_toggle-1);
        qi->setProperty(_property.toLatin1().constData(),_onValue);
        _lastToggled = qi;
        emit toggleChanged();
    }
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
