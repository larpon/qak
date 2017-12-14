#ifndef QAK_ITEMANIMATIONPRIVATE_H
#define QAK_ITEMANIMATIONPRIVATE_H


#include <QDebug>
#include <QQuickItem>
#include <QSGSimpleRectNode>

class ItemAnimationPrivate : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(bool running READ running WRITE setRunning NOTIFY runningChanged)
    Q_PROPERTY(int frame READ frame WRITE setFrame NOTIFY frameChanged)
    Q_PROPERTY(QString goalSequence READ goalSequence WRITE setGoalSequence NOTIFY goalSequenceChanged)

public:
    ItemAnimationPrivate(QQuickItem* parent = 0);

    void componentComplete();

    bool running() const;
    int frame() const;

    QString goalSequence() const;

signals:
    void runningChanged();
    void frameChanged();
    void goalSequenceChanged();


public slots:
    void setRunning(bool running);
    void setFrame(int frame);
    void setGoalSequence(const QString &goalSequence);

    //void setDynamicProperty(QObject *object, const QString &name, const QVariant &value);

private:
    bool _running;
    int _frame;
    QString _goalSequence;

};

#endif // QAK_ITEMANIMATIONPRIVATE
