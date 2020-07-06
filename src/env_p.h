#ifndef QAK_ENV_PRIVATE_H
#define QAK_ENV_PRIVATE_H

#include <QDebug>
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QVariant>
#include <QMoveEvent>
#include <QWindow>
#include <QApplication>
#include <QResource>
#include <QTranslator>
#include <QQuickItem>
#include <QQmlEngine>
#include <QQmlContext>

#include <QtGui/QGuiApplication>

#if defined(Q_OS_ANDROID)
#include <QAndroidJniEnvironment>
#include <QAndroidJniObject>
#include <QtAndroid>

#if QT_VERSION < QT_VERSION_CHECK(5, 10, 0)
#include "permissions.h"
#endif

#endif

namespace Qak {
    class AndroidEnv : public QObject
    {
        Q_OBJECT
    public:
        AndroidEnv(QObject *parent = 0);

        Q_INVOKABLE static QString obbPath();

        Q_INVOKABLE static bool checkPermission(const QString &permission);

    private:

    };
}

namespace Qak {
    class MouseEnv : public QObject
    {
        Q_OBJECT

    public:
        MouseEnv(QObject *parent = 0);

        Q_INVOKABLE static void press(QObject *target, const QPointF &point);
        Q_INVOKABLE static void release(QObject *target, const QPointF &point);
        Q_INVOKABLE static void move(QObject *target, const QPointF &point);

    private:

    };
}

class EnvPrivate : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Qak::AndroidEnv *android READ androidEnv)
    Q_PROPERTY(Qak::MouseEnv *mouse READ mouseEnv)

public:
    EnvPrivate(QObject* parent = nullptr);

    Q_INVOKABLE static QString appPath();
    Q_INVOKABLE static QString dataPath();
    Q_INVOKABLE static QString cachePath();
    Q_INVOKABLE static QString configPath();
    Q_INVOKABLE static QString tempPath();

    Q_INVOKABLE static bool copy(const QString &src, const QString &dst);
    Q_INVOKABLE static bool copy(const QString &src, const QString &dst, bool recursively);

    Q_INVOKABLE static bool remove(const QString &path);

    Q_INVOKABLE QString read(const QString &path);

    Q_INVOKABLE bool write(const QString& data, const QString &path);
    Q_INVOKABLE bool write(const QString& data, const QString &path, bool overwrite);

    Q_INVOKABLE static QStringList list(const QString &dir);
    Q_INVOKABLE static QStringList list(const QString &dir, bool recursively);

    Q_INVOKABLE static bool ensure(const QString &path);

    Q_INVOKABLE static bool exists(const QString &path);
    Q_INVOKABLE static bool isFile(const QString &path);
    Q_INVOKABLE static bool isDir(const QString &path);

    Q_INVOKABLE static qint64 size(const QString &path);

    Q_INVOKABLE static bool registerResource(const QString &rccFilename, const QString &resourceRoot=QString());
    Q_INVOKABLE static bool unregisterResource(const QString &rccFilename, const QString &resourceRoot=QString());

    Q_INVOKABLE void setLanguage(const QString &languageCode);
    // TODO move to seperate type / remove ?
    //Q_INVOKABLE static void click(const QPointF point);

    Qak::AndroidEnv *androidEnv();
    Qak::MouseEnv *mouseEnv();

private:
    static QString subEnvPath();
    Qak::AndroidEnv _androidEnv;
    Qak::MouseEnv _mouseEnv;

    QTranslator m_translator;
};

#endif // QAK_ENV_PRIVATE_H
