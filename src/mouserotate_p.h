#ifndef QAK_MOUSEROTATEPRIVATE_H
#define QAK_MOUSEROTATEPRIVATE_H

#include <QObject>

#include <QTimer>
#include <QThread>
#include <QtMath>

//#include <QTimerEvent>
#include <QDebug>

class MouseRotatePrivate : public QObject
{
    Q_OBJECT

    Q_PROPERTY(qreal tick READ getTick WRITE setTick NOTIFY tick)
    Q_PROPERTY(qreal previousTick READ getPreviousTick NOTIFY previousTickChanged)

    Q_PROPERTY(qreal normalized READ getNormalized NOTIFY normalizedChanged)
    Q_PROPERTY(int rounds READ getRounds NOTIFY roundsChanged)

    Q_PROPERTY(bool flipping READ isFlipping WRITE setFlipping NOTIFY flippingChanged)
    Q_PROPERTY(bool wrapTicks READ getWrapTicks WRITE setWrapTicks NOTIFY wrapTicksChanged)

public:
    explicit MouseRotatePrivate(QObject *parent = 0);

    qreal getTick() const;
    void setTick(qreal tick);

    qreal getPreviousTick() const;
    void setPreviousTick(const qreal &previousTick);

    qreal getNormalized() const;

    int getRounds() const;

    bool isFlipping() const;
    void setFlipping(bool flipping);

    bool getWrapTicks() const;
    void setWrapTicks(bool wrapTicks);

signals:

    void tick();
    void previousTickChanged();

    void normalizedChanged();

    void roundsChanged();

    void flippingChanged();
    void wrapTicksChanged();

public slots:
    void doTick();

protected:
    //void timerEvent(QTimerEvent *event);

private:

    qreal _tick;
    qreal _previousTick;

    qreal _normalized;
    int _rounds;

    bool _flipping;
    bool _wrapTicks;

    void recalculateNormalized();
    qreal normalize(qreal value, qreal start, qreal end);

};

#endif // QAK_MOUSEROTATEPRIVATE_H
