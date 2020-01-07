#ifndef QAK_AID_PRIVATE_H
#define QAK_AID_PRIVATE_H

#include <QJSValue>
//#include <QQmlProperty>
#include <QDebug>

class AidPrivate : public QObject
{
    Q_OBJECT

public:
    AidPrivate(QObject* parent = nullptr);

    Q_INVOKABLE qreal remap(qreal oldValue, qreal oldMin, qreal oldMax, qreal newMin, qreal newMax);

    Q_INVOKABLE bool isArray(QVariant o);
    Q_INVOKABLE bool isObject(QVariant o);
    Q_INVOKABLE bool isString(QVariant o);

    Q_INVOKABLE void inspect(QVariant o);
    Q_INVOKABLE bool hasProperty(QVariant o, QString p);

    Q_INVOKABLE bool undefinedOrNull(QVariant o);

    Q_INVOKABLE qreal interpolate(qreal x0, qreal x1, qreal alpha);
    Q_INVOKABLE qreal lerp(qreal x0, qreal x1, qreal alpha);

    //Q_INVOKABLE qreal normalize0to360(qreal degrees);
private:
    QJSValue jsv;
};

#endif // QAK_AID_PRIVATE
