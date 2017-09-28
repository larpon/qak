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

    Q_PROPERTY(qreal rotation READ getRotation WRITE setRotation NOTIFY rotated)
    Q_PROPERTY(qreal previousRotation READ getPreviousRotation NOTIFY previousRotationChanged)

    Q_PROPERTY(qreal normalized READ getNormalized NOTIFY normalizedChanged)
    Q_PROPERTY(int rounds READ getRounds NOTIFY roundsChanged)

    Q_PROPERTY(bool flipping READ isFlipping WRITE setFlipping NOTIFY flippingChanged)
    Q_PROPERTY(bool wrap READ getWrap WRITE setWrap NOTIFY wrapChanged)

    Q_PROPERTY(bool continuous READ getContinuous WRITE setContinuous NOTIFY continuousChanged)
    Q_PROPERTY(bool continuousInfinite READ getContinuousInfinite WRITE setContinuousInfinite NOTIFY continuousInfiniteChanged)
    Q_PROPERTY(qreal continuousMin READ getContinuousMin WRITE setContinuousMin NOTIFY continuousMinChanged)
    Q_PROPERTY(qreal continuousMax READ getContinuousMax WRITE setContinuousMax NOTIFY continuousMaxChanged)

    Q_PROPERTY(qreal min READ getMin WRITE setMin NOTIFY minChanged)
    Q_PROPERTY(qreal max READ getMax WRITE setMax NOTIFY maxChanged)
public:
    explicit MouseRotatePrivate(QObject *parent = 0);

    qreal getRotation() const;


    qreal getPreviousRotation() const;
    void setPreviousRotation(const qreal &previousRotation);

    qreal getNormalized() const;

    int getRounds() const;

    bool isFlipping() const;
    void setFlipping(bool flipping);

    bool getWrap() const;
    void setWrap(bool wrap);

    bool getContinuous() const;
    void setContinuous(bool continuous);

    bool getContinuousInfinite() const;
    void setContinuousInfinite(bool continuousInfinite);

    qreal getContinuousMax() const;
    void setContinuousMax(const qreal &continuousMax);

    qreal getContinuousMin() const;
    void setContinuousMin(const qreal &continuousMin);

    qreal getMin() const;
    void setMin(const qreal &min);

    qreal getMax() const;
    void setMax(const qreal &max);

signals:

    void rotated();
    void previousRotationChanged();

    void normalizedChanged();

    void roundsChanged();

    void flippingChanged();
    void wrapChanged();

    void continuousChanged();
    void continuousInfiniteChanged();
    void continuousMinChanged();
    void continuousMaxChanged();

    void minChanged();
    void maxChanged();

public slots:
    void setRotation(qreal rotation);

protected:
    //void timerEvent(QTimerEvent *event);

private:

    qreal _rotation;
    qreal _previousRotation;

    qreal _normalized;
    int _rounds;

    bool _flipping;
    bool _wrap;
    bool _continuous;
    bool _continuousInfinite;
    qreal _continuousMin;
    qreal _continuousMax;

    qreal _min;
    qreal _max;

    void recalculateNormalized();
    qreal normalize(qreal value, qreal start, qreal end);

};

#endif // QAK_MOUSEROTATEPRIVATE_H
