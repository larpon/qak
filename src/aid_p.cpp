#include "aid_p.h"

AidPrivate::AidPrivate(QObject *parent) : QObject(parent)
{

}

qreal AidPrivate::remap(qreal oldValue, qreal oldMin, qreal oldMax, qreal newMin, qreal newMax)
{
    //if(oldMin == newMin && oldMax == newMax)
    //    return oldValue;
    // Linear conversion
    // NewValue = (((OldValue - OldMin) * (NewMax - NewMin)) / (OldMax - OldMin)) + NewMin
    return (((oldValue - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) + newMin;
}

bool AidPrivate::isArray(QVariant o)
{
    return o.canConvert<QJSValue>() && o.value<QJSValue>().isArray();
}

bool AidPrivate::isObject(QVariant o)
{
    if(QString::fromUtf8(o.typeName()) == "QObject*")
        return true;

    if(QString::fromUtf8(o.typeName()) == "QUrl")
        return true;

    if(QString::fromUtf8(o.typeName()) == "QPointF" || QString::fromUtf8(o.typeName()) == "QPoint")
        return true;

    if(o.canConvert<QJSValue>()) {
        QJSValue jsv = o.value<QJSValue>();
        return  jsv.isObject() && !jsv.isArray() && !undefinedOrNull(o);
    }
    //qDebug() << "Couldn't recognize " << o.typeName() << " as object";
    return false;
}

bool AidPrivate::isString(QVariant o)
{
    /*if(o.canConvert<QJSValue>()) {
        return o.value<QJSValue>().isString();
    }*/
    return QString::fromUtf8(o.typeName()) == "QString";
}

void AidPrivate::inspect(QVariant o)
{
    qDebug() << "INSPECT" << o.typeName();
    if(o.canConvert<QRect>() || o.canConvert<QRectF>())
        qDebug() << "QRect";
    if(o.canConvert<QPoint>() || o.canConvert<QPointF>())
        qDebug() << "QPoint";
    if(o.canConvert<QSize>() || o.canConvert<QSizeF>())
        qDebug() << "QSize";
    if(o.canConvert<QJSValue>()) {
        QJSValue jsv = o.value<QJSValue>();
        qDebug() << (jsv.isNull() ? "null" : "") <<
                    (jsv.isUndefined() ? "undefined" : "") <<
                    (jsv.isBool() ? "bool" : "") <<
                    (jsv.isDate() ? "date" : "") <<
                    (jsv.isArray() ? "array" : "") <<
                    (jsv.isError() ? "error" : "") <<
                    (jsv.isNumber() ? "number" : "") <<
                    (jsv.isObject() ? "object" : "") <<
                    (jsv.isRegExp() ? "regex" : "") <<
                    (jsv.isString() ? "string" : "") <<
                    (jsv.isQObject() ? "qobject" : "") <<
                    (jsv.isVariant() ? "variant" : "") <<
                    (jsv.isCallable() ? "callable" : "") <<
                    (jsv.isQMetaObject() ? "qmetaobject" : "")
                    ;
    }
}

bool AidPrivate::undefinedOrNull(QVariant o)
{
    if(o.canConvert<QJSValue>()) {
        jsv = o.value<QJSValue>();
        return jsv.isUndefined() || jsv.isNull();
    }
    return false;
}

qreal AidPrivate::interpolate(qreal x0, qreal x1, qreal alpha)
{
    return (x0 * (1 - alpha) + alpha * x1);
}

qreal AidPrivate::lerp(qreal x0, qreal x1, qreal alpha)
{
    return interpolate(x0, x1, alpha);
}

/*
qreal AidPrivate::normalize0to360(qreal degrees)
{
    degrees = static_cast<int>(degrees + degrees < 0.0 ? -0.5 : 0.5) % 360;
    if (degrees < 0)
        degrees += 360;
    return degrees;
}*/

bool AidPrivate::hasProperty(QVariant o, QString p)
{
    if(isObject(o)) {
        QObject *supposedQObject = o.value<QObject*>();
        if(supposedQObject != nullptr) {
            //inspect(o);
            //qDebug() << supposedQObject->metaObject()->className() << supposedQObject->inherits("QQuickItem");
            //qDebug() << "QMLProp" << QQmlProperty::read(supposedQObject, p).isValid();

            if(supposedQObject->inherits("QQuickItem")) {
                QList<QString> list = {
                    "childAt", "contains", "forceActiveFocus","forceActiveFocus","grabToImage",
                    "mapFromGlobal","mapFromItem","mapToGlobal","mapToItem",
                    "nextItemInFocusChain"
                };
                if(list.indexOf(p) != -1) {
                    return true;
                }

                if(supposedQObject->metaObject()->indexOfMethod(p.toLocal8Bit().data()) > -1) {
                    //qDebug() << p.toLocal8Bit().data() << "is a method at";
                    return true;
                }
                //qDebug() << supposedQObject->metaObject()->indexOfMethod(p.toLocal8Bit().data());
            }
            return supposedQObject->property(p.toLocal8Bit().data()).isValid();
        }
        if(o.canConvert<QJSValue>())
            return o.value<QJSValue>().hasProperty(p);
    }
    return false;
}

