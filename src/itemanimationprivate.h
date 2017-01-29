#ifndef QAK_ITEMANIMATIONPRIVATE_H
#define QAK_ITEMANIMATIONPRIVATE_H


#include <QDebug>
#include <QQuickItem>
#include <QSGSimpleRectNode>

class ItemAnimationPrivate : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(bool running READ running WRITE setRunning NOTIFY runningChanged)

public:
    ItemAnimationPrivate(QQuickItem* parent = 0);

    void componentComplete();

    bool running() const;

    int frame() const;
    void setFrame(int frame);

signals:
    void runningChanged();
    void frameChanged();


public slots:
    void setRunning(bool running);
    void setDynamicProperty(QObject *object, const QString &name, const QVariant &value);

private:
    bool _running;
    int _frame;

};

#endif // QAK_ITEMANIMATIONPRIVATE
