#ifndef QAK_ITEMTOGGLE_H
#define QAK_ITEMTOGGLE_H


#include <QDebug>
#include <QQuickItem>
#include <QSGSimpleRectNode>

class PropertyToggle : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(QString property READ property WRITE setProperty NOTIFY propertyChanged)
    Q_PROPERTY(QVariant on READ onValue WRITE setOnValue NOTIFY onChanged)
    Q_PROPERTY(QVariant off READ offValue WRITE setOffValue NOTIFY offChanged)
    Q_PROPERTY(int toggle READ toggle WRITE setToggle NOTIFY toggleChanged)


public:
    PropertyToggle(QQuickItem* parent = 0);

    void componentComplete();
    void itemChange(ItemChange change, const ItemChangeData &value);

    bool enabled() const;
    void setEnabled(bool enabled);

    QString property() const;
    void setProperty(const QString &property);

    QVariant onValue() const;
    void setOnValue(const QVariant &onValue);

    QVariant offValue() const;
    void setOffValue(const QVariant &offValue);

    int toggle() const;
    void setToggle(int toggle);

    Q_INVOKABLE void clear();

signals:
    void enabledChanged();
    void propertyChanged();
    void onChanged();
    void offChanged();
    void toggleChanged();

public slots:
    void next();
    void previous();

private:
    bool _enabled;
    QString _property;
    QVariant _onValue;
    QVariant _offValue;
    int _toggle;

    QList<QQuickItem *>	_children;
    QQuickItem *_lastToggled;

    void ensureProperty();
};

#endif // QAK_ITEMTOGGLE_H
