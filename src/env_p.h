#ifndef QAK_PATH_PRIVATE_H
#define QAK_PATH_PRIVATE_H

#include <QDebug>
#include <QStandardPaths>
#include <QDir>

#include <QtGui/QGuiApplication>

class EnvPrivate : public QObject
{
    Q_OBJECT

public:
    EnvPrivate(QObject* parent = 0);

    Q_INVOKABLE static QString config();
};

#endif // QAK_PATH_PRIVATE_H
