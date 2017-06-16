#include "resource.h"

Resource::Resource(QObject* parent) : QObject(parent)
{
    _networkManager = new QNetworkAccessManager(this);
    _dataPath = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    _cachePath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    _baseUrl = "http://example.com/resource";
    _prefix = "";

    // Remember the bug where you connected multiple times in the load() function - only connect once :)
    QObject::connect(_networkManager, SIGNAL(finished(QNetworkReply*)), this, SLOT(onNetworkReply(QNetworkReply*)));

    if(ensure(_dataPath))
        qDebug() << "Created data directory" << _dataPath;
    else
        emit error("Failed creating data directory "+_dataPath);

    if(ensure(_cachePath))
        qDebug() << "Created cache directory" << _cachePath;
    else
        emit error("Failed creating cache directory "+_cachePath);

}


QString Resource::prefix()
{
    return _prefix;
}

void Resource::setPrefix(const QString &prefix)
{
    if (prefix != _prefix) {
        _prefix = prefix;
        emit prefixChanged();
    }
}

bool Resource::available(const QString &name)
{
    QFile file(resourceFile(name));
    return file.exists();
}

bool Resource::exists(const QString &path)
{
    QString source = QString(path);
    source = source.replace("qrc://",":");
    source = source.replace("file://","");

    QFile file(source);
    //qDebug() << "Checking" << source;
    //QFile file(QString(path).replace("qrc://",":"));
    return file.exists();
}


bool Resource::copy(const QString &source, const QString &destination)
{
    QString src = QString(source);
    src = src.replace("qrc://",":");
    src = src.replace("file://","");

    // TODO check that destination is not qrc
    QString dest = QString(destination);
    dest = dest.replace("qrc://",":");
    dest = dest.replace("file://","");

    QFileInfo dest_info = QFileInfo(dest);

    if(ensure(dest_info.path()))
        qDebug() << "Created destination directory" << dest_info.path();
    else
        emit error("Failed creating destination directory "+dest_info.path());

    return QFile::copy(src , dest);
}

bool Resource::ensure(const QString &path)
{
    QDir dir(path);
    if (!dir.exists())
        return dir.mkpath(".");
    return false;
}

bool Resource::clearDataPath()
{
    QDir dir(dataPath());
    return dir.removeRecursively();
}

bool Resource::clearCachePath()
{
    QDir dir(cachePath());
    return dir.removeRecursively();
}

void Resource::load(const QString &name)
{
    QUrl url = resourceUrl(name);
    _networkManager->get(QNetworkRequest(url));
}

bool Resource::unload(const QString &name)
{
    if(available(name))
    {
        bool unloadSuccess = QResource::unregisterResource(resourceFile(name),"/"+name+"/");
        emit unloaded(name);
        return unloadSuccess;
    }
    return false;
}

void Resource::onNetworkReply(QNetworkReply* reply)
{
    if(reply->error() == QNetworkReply::NoError)
    {
        int httpstatuscode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toUInt();
        switch(httpstatuscode)
        {
            case 200:
            if (reply->isReadable())
            {
                QString name = resourceName(reply->request().url());

                //Assuming this is a human readable file replyString now contains the file
                //replyString = QString::fromUtf8(reply->readAll().data());

                QByteArray data = reply->readAll();
                qDebug() << "resources.cpp" << name;

                QString resName = resourceFile(name);
                QFile file(resName);
                file.open(QIODevice::WriteOnly);
                qint64 result = file.write(data);
                file.close();
                if(result > -1) {
                    QResource::registerResource(resName,"/"+name+"/");
                    emit loaded(name);
                } else
                    emit error(name);
            }
            break;
            case 404:
            case 333:
            default:
                break;
        }
    } else {
        emit networkError(reply->error(),reply->errorString());
    }

    reply->deleteLater();
}

QString Resource::resourceFile(const QString &name)
{
    return _dataPath+"/"+name+".rcc";
}

QUrl Resource::resourceUrl(const QString &name)
{
    return _baseUrl+"/"+name+".rcc";
}

QString Resource::resourceName(const QUrl &url)
{
    QFileInfo fi(url.fileName());
    return fi.baseName();
}

QString Resource::resourceName(const QString &str)
{
    QFileInfo fi(str);
    return fi.baseName();
}

QString Resource::appPath()
{
    return QDir::currentPath();
}

QString Resource::dataPath()
{
    return _dataPath;
}

QString Resource::cachePath()
{
    return _cachePath;
}

QString Resource::fileMD5Hash(const QUrl &url)
{
    QFile file(url.toString().replace("qrc://",":"));
    if(!file.exists())
        return "deadbeef";
    file.open(QIODevice::ReadOnly);
    return QString(QCryptographicHash::hash(file.readAll(),QCryptographicHash::Md5).toHex());
}

QString Resource::url(const QString &relativePath)
{
    QString const prefixed = _prefix + relativePath;
    QString fullPath = "";

    #if defined(Q_OS_ANDROID)
        fullPath = "assets:/" + relativePath;
    #else
        fullPath = "qrc:///"+prefixed;
    #endif

    return fullPath;
}
