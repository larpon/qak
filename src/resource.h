#ifndef RESOURCE_H
#define RESOURCE_H

#include <QDebug>
#include <QDir>
#include <QFile>
#include <QResource>
#include <QStandardPaths>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>

class Resource : public QObject
{
    Q_OBJECT
    //Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)

    public:
        explicit Resource(QObject* parent = 0);

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

#endif // RESOURCE_H
