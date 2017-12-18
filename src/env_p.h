#ifndef QAK_PATH_PRIVATE_H
#define QAK_PATH_PRIVATE_H

#include <QDebug>
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QVariant>

#include <QtGui/QGuiApplication>

class EnvPrivate : public QObject
{
    Q_OBJECT

public:
    EnvPrivate(QObject* parent = 0);

    Q_INVOKABLE static QString dataPath();
    Q_INVOKABLE static QString cachePath();
    Q_INVOKABLE static QString configPath();

    Q_INVOKABLE static bool copy(const QString &src, const QString &dst);
    Q_INVOKABLE static bool copy(const QString &src, const QString &dst, bool recursively);

    Q_INVOKABLE static bool remove(const QString &path);

    Q_INVOKABLE static QStringList list(const QString &dir);
    Q_INVOKABLE static QStringList list(const QString &dir, bool recursively);

    Q_INVOKABLE static bool ensure(const QString &path);

    Q_INVOKABLE static bool exists(const QString &path);
    Q_INVOKABLE static bool isFile(const QString &path);
    Q_INVOKABLE static bool isDir(const QString &path);


private:
    static QString subEnvPath();
};

#endif // QAK_PATH_PRIVATE_H
