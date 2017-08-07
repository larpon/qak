#ifndef QAK_AID_PRIVATE_H
#define QAK_AID_PRIVATE_H

#include <QDebug>
#include <QQuickItem>

class AidPrivate : public QObject
{
    Q_OBJECT

public:
    AidPrivate(QObject* parent = 0);

    Q_INVOKABLE qreal remap(qreal oldValue, qreal oldMin, qreal oldMax, qreal newMin, qreal newMax);
};

#endif // QAK_AID_PRIVATE
