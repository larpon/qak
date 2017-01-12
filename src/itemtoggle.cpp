#include "itemtoggle.h"

ItemToggle::ItemToggle(QQuickItem* parent):QQuickItem(parent)
{
    setFlag(ItemHasContents, true);
    update();
}

void ItemToggle::componentComplete()
{
    QList<QQuickItem *>	children = childItems();
    foreach(QQuickItem *qi, children) {
        qi->setOpacity(0.5);
        qDebug() << this << "::componentComplete" << "loop" << qi;
    }
}

QString ItemToggle::property() const
{
    return _property;
}

void ItemToggle::setProperty(const QString &property)
{
    _property = property;
}
