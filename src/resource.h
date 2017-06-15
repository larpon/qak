#ifndef RESOURCE_H
#define RESOURCE_H

#include <QQmlEngine>
#include <QJSEngine>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QResource>
#include <QStandardPaths>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QCryptographicHash>

#include "qqml.h"

class Resource : public QObject
{
    Q_OBJECT
    //Q_DISABLE_COPY(Resource) <- If singleton

    Q_PROPERTY(QString prefix READ prefix WRITE setPrefix NOTIFY prefixChanged)

    public:
        explicit Resource(QObject* parent = 0);

        QString prefix();
        void setPrefix(const QString &prefix);

    signals:
        void loaded(const QString &name);
        void unloaded(const QString &name);
        void error(const QString& msg);
        void networkError(const quint64& error, const QString& msg);
        void prefixChanged();

    public slots:
        void load(const QString &name);
        bool unload(const QString &name);
        bool available(const QString &name);
        bool exists(const QString &name);
        bool copy(const QString &source, const QString &destination);
        bool ensure(const QString &path);
        bool clearDataPath();
        bool clearCachePath();
        QString appPath();
        QString dataPath();
        QString cachePath();
        QString fileMD5Hash(const QUrl &url);
        QString url(const QString &relativePath);

    private slots:
        void onNetworkReply(QNetworkReply* reply);

    private:
        QNetworkAccessManager* _networkManager;
        QString resourceFile(const QString &name);
        QUrl resourceUrl(const QString &name);
        QString resourceName(const QUrl &url);
        QString resourceName(const QString &str);
        QString _dataPath;
        QString _cachePath;
        QString _baseUrl;
        QString _prefix;


};

/* NOTE example of exposing as singleton object in QML
// Second, define the singleton type provider function (callback).
static QObject *ResourceQmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);

    Resource *resource = new Resource();
    //QQmlEngine::setObjectOwnership( resource, QQmlEngine::CppOwnership );
    return resource;
}

class ResourceRegisterHelper {

public:
    ResourceRegisterHelper() {
        qmlRegisterSingletonType<Resource>("Qak", 1, 0, "Resource", ResourceQmlInstance);
    }
};

static ResourceRegisterHelper resourceRegisterHelper;
*/

#endif // RESOURCE_H
