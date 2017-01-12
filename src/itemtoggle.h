#ifndef QAK_ITEMTOGGLE_H
#define QAK_ITEMTOGGLE_H

#include <QQuickItem>

class ItemToggle : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(QString property READ property WRITE setProperty NOTIFY propertyChanged)
public:
    explicit ItemToggle(QQuickItem* parent = 0);

    void componentComplete();

    QString property() const;
    void setProperty(const QString &property);

signals:
    void propertyChanged();

public slots:

private:
    bool _running;
    QVariantList _sequences;

    QString _property;
};

#endif // QAK_ITEMTOGGLE_H
