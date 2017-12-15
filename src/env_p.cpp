#include "env_p.h"

EnvPrivate::EnvPrivate(QObject *parent)
    : QObject(parent)
{

}

QString EnvPrivate::dataPath()
{
    return QStandardPaths::writableLocation(QStandardPaths::DataLocation)+QDir::separator()+subEnvPath();
}

QString EnvPrivate::cachePath()
{
    return QStandardPaths::writableLocation(QStandardPaths::CacheLocation)+QDir::separator()+subEnvPath();
}

QString EnvPrivate::configPath()
{
    return QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)+QDir::separator()+subEnvPath();
}

bool EnvPrivate::copy(const QString &src, const QString &dst)
{
    return copy(src, dst, true);
}

bool EnvPrivate::copy(const QString &src, const QString &dst, bool recursively)
{
    if(isFile(src)) {
        // File copy
        return QFile::copy(src , dst);
    }

    if(isDir(src)) {

        bool success = false;

        if(isFile(dst)) {
            qWarning() << "Qak" << "Env::copy" << dst << "is a file";
            return false;
        }

        // Directory copy
        QDir sourceDir(src);

        if(!isDir(dst))
            ensure(dst);

        QStringList entries = sourceDir.entryList(QDir::Files);

        // Copy files first
        for(int i = 0; i< entries.count(); i++) {
            success = QFile::copy(src + QDir::separator() + entries[i],
                                  dst + QDir::separator() + entries[i]);
            if(!success)
                return false;
        }

        if(recursively) {
            // Copy directories
            entries.clear();
            entries = sourceDir.entryList(QDir::AllDirs | QDir::NoDotAndDotDot);
            for(int i = 0; i< entries.count(); i++)
            {
                success = copy(src + QDir::separator() + entries[i],
                               dst + QDir::separator() + entries[i],
                               recursively);
                if(!success)
                    return false;
            }
        }

        return true;
    }

    return false;
}

bool EnvPrivate::ensure(const QString &path)
{
    QDir dir(path);
    if (!dir.exists())
        return dir.mkpath(".");
    return false;
}

bool EnvPrivate::exists(const QString &path)
{
    QFileInfo check(path);
    return check.exists();
}

bool EnvPrivate::isFile(const QString &path)
{
    QFileInfo check(path);
    return check.exists() && check.isFile();
}

bool EnvPrivate::isDir(const QString &path)
{
    QFileInfo check(path);
    return check.exists() && check.isDir();
}

QString EnvPrivate::subEnvPath()
{
    QString sub;
    if(QGuiApplication::organizationName() != "")
        sub += QGuiApplication::organizationName() + QDir::separator();
    if(QGuiApplication::organizationDomain() != "")
        sub += QGuiApplication::organizationDomain() + QDir::separator();
    if(QGuiApplication::applicationName() != "")
        sub += QGuiApplication::applicationName() + QDir::separator();
    #ifdef QAK_STORE_VERSION_PATH
    if(QGuiApplication::applicationVersion() != "")
        sub += QGuiApplication::applicationVersion() + QDir::separator() ;
    #endif
    if(sub == "") {
         qWarning() << "Qak" << "Env" << "Couldn't resolve" << sub << "as a valid path. Using generic directory: \"Qak\"";
         sub = "Qak";
    }

    while(sub.endsWith( QDir::separator() )) sub.chop(1);

    return sub;
}
