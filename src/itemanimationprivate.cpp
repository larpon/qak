#include "itemanimationprivate.h"


ItemAnimationPrivate::ItemAnimationPrivate(QQuickItem* parent)
    : QQuickItem(parent)
{
    _running = false;
    setFlag(ItemHasContents);
}

void ItemAnimationPrivate::componentComplete()
{
    // NOTE it's important to call the base class method
    QQuickItem::componentComplete();
}

bool ItemAnimationPrivate::running() const
{
    return _running;
}

void ItemAnimationPrivate::setRunning(bool running)
{
    if(_running != running) {
        _running = running;
        emit runningChanged();
    }
}

void ItemAnimationPrivate::setDynamicProperty(QObject *object, const QString &name, const QVariant &value)
{
    object->setProperty(name.toLatin1().constData(),value);
}

int ItemAnimationPrivate::frame() const
{
    return _frame;
}

void ItemAnimationPrivate::setFrame(int frame)
{
    if(_frame != frame) {
        _frame = frame;
        emit frameChanged();
    }
}
