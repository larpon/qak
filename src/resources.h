#ifndef RESOURCES_H
#define RESOURCES_H

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

#include "qqml.h"

class Resources : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(Resources)
    //Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)

    public:
        explicit Resources(QObject* parent = 0);

    signals:
        void loaded(const QString &name);
        void unloaded(const QString &name);
        void error(const QString& msg);
        void networkError(const quint64& error, const QString& msg);

    public slots:
        void load(const QString &name);
        bool unload(const QString &name);
        bool available(const QString &name);
        bool exists(const QString &name);
        QString appPath();

    private slots:
        void onNetworkReply(QNetworkReply* reply);

    private:
        QNetworkAccessManager* _networkManager;
        QString resourceFile(const QString &name);
        QUrl resourceUrl(const QString &name);
        QString resourceName(const QUrl &url);
        QString resourceName(const QString &str);
        QString _dataPath;
        QString _baseUrl;


};

// Second, define the singleton type provider function (callback).
static QObject *ResourcesQmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);

    Resources *resources = new Resources();
    //QQmlEngine::setObjectOwnership( resources, QQmlEngine::CppOwnership );
    return resources;
}

class ResourcesRegisterHelper {

public:
    ResourcesRegisterHelper() {
        qmlRegisterSingletonType<Resources>("Qak", 1, 0, "Resources", ResourcesQmlInstance);
    }
};

static ResourcesRegisterHelper resourcesRegisterHelper;


#endif // RESOURCES_H
