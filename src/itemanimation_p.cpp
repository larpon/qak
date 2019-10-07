#include "itemanimation_p.h"


ItemAnimationPrivate::ItemAnimationPrivate(QQuickItem* parent)
    : QQuickItem(parent)
{
    _frame = 0;
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

/* TODO NICE TO HAVE
void ItemAnimationPrivate::setDynamicProperty(QObject *object, const QString &name, const QVariant &value)
{
    object->setProperty(name.toLatin1().constData(),value);
}
*/

QString ItemAnimationPrivate::goalSequence() const
{
    return _goalSequence;
}

void ItemAnimationPrivate::setGoalSequence(const QString &goalSequence)
{
    if(_goalSequence != goalSequence) {
        _goalSequence = goalSequence;
        emit goalSequenceChanged();
    }
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
