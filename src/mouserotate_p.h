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

signals:

    void rotated();
    void previousRotationChanged();

    void normalizedChanged();

    void roundsChanged();

    void flippingChanged();
    void wrapChanged();
    void continuousChanged();

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

    void recalculateNormalized();
    qreal normalize(qreal value, qreal start, qreal end);

};

#endif // QAK_MOUSEROTATEPRIVATE_H
