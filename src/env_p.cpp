#include "env_p.h"


Qak::AndroidEnv::AndroidEnv(QObject *parent)
    : QObject(parent)
{

}

QString Qak::AndroidEnv::obbPath()
{
    #if defined(Q_OS_ANDROID)
    QAndroidJniObject mediaDir = QAndroidJniObject::callStaticObjectMethod( "android/os/Environment", "getExternalStorageDirectory", "()Ljava/io/File;");
    QAndroidJniObject mediaPath = mediaDir.callObjectMethod( "getAbsolutePath", "()Ljava/lang/String;" );
    QAndroidJniObject activity = QAndroidJniObject::callStaticObjectMethod( "org/qtproject/qt5/android/QtNative" , "activity", "()Landroid/app/Activity;");
    QAndroidJniObject package = activity.callObjectMethod( "getPackageName", "()Ljava/lang/String;");

    // If any exceptions occurred - just clear them and move on
    QAndroidJniEnvironment env;
    if (env->ExceptionCheck()) {
        qWarning() << "Qak" << "Env::obbPath" << "Exception occurred"; // << env->ExceptionDescribe();
        env->ExceptionClear();
    }

    return mediaPath.toString()+QStringLiteral("/Android/obb/")+package.toString();
    #endif
    return QStringLiteral("");
}

bool Qak::AndroidEnv::checkPermission(const QString &permission)
{
    #if defined(Q_OS_ANDROID)
    QtAndroid::PermissionResult r = QtAndroid::checkPermission(permission);
    if(r == QtAndroid::PermissionResult::Denied) {
        QtAndroid::requestPermissionsSync( QStringList() << permission );
        r = QtAndroid::checkPermission(permission);
        if(r == QtAndroid::PermissionResult::Denied) {
            return false;
        }
    }
    #else
    Q_UNUSED(permission);
    return false;
    #endif
    return true;
}


Qak::MouseEnv::MouseEnv(QObject *parent)
    : QObject(parent)
{

}

void Qak::MouseEnv::press(QObject *target, const QPointF &point)
{
    QMouseEvent *event = new QMouseEvent(QEvent::MouseButtonPress, point,
            Qt::LeftButton,
            Qt::LeftButton,
            Qt::NoModifier );

    if(target == nullptr)
        target = qApp->focusWindow();
    qDebug() << "Env.mouse::press" << target << point;
    qApp->postEvent(target, event);
}

void Qak::MouseEnv::release(QObject *target, const QPointF &point)
{
    QMouseEvent *event = new QMouseEvent(QEvent::MouseButtonRelease, point,
            Qt::LeftButton,
            Qt::LeftButton,
            Qt::NoModifier );

    if(target == nullptr)
        target = qApp->focusWindow();
    qDebug() << "Env.mouse::release" << target << point;
    qApp->postEvent(target, event);
}

void Qak::MouseEnv::move(QObject *target, const QPointF &point)
{
    QMouseEvent *event = new QMouseEvent(QEvent::MouseMove, point,
            Qt::LeftButton,
            Qt::LeftButton,
            Qt::NoModifier );

    if(target == nullptr)
        target = qApp->focusWindow();
    qDebug() << "Env.mouse::move" << target << point;
    qApp->postEvent(target, event);
}

EnvPrivate::EnvPrivate(QObject *parent)
    : QObject(parent)
{

}

QString EnvPrivate::appPath()
{
    return QCoreApplication::applicationDirPath();
}

QString EnvPrivate::dataPath()
{
    return QStandardPaths::writableLocation(QStandardPaths::DataLocation)+QStringLiteral("/")+subEnvPath();
}

QString EnvPrivate::cachePath()
{
    return QStandardPaths::writableLocation(QStandardPaths::CacheLocation)+QStringLiteral("/")+subEnvPath();
}

QString EnvPrivate::configPath()
{
    return QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)+QStringLiteral("/")+subEnvPath();
}

QString EnvPrivate::tempPath()
{
    return QStandardPaths::writableLocation(QStandardPaths::TempLocation)+QStringLiteral("/")+subEnvPath();
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
            success = QFile::copy(src + QStringLiteral("/") + entries[i],
                                  dst + QStringLiteral("/") + entries[i]);
            if(!success)
                return false;
        }

        if(recursively) {
            // Copy directories
            entries.clear();
            entries = sourceDir.entryList(QDir::AllDirs | QDir::NoDotAndDotDot);
            for(int i = 0; i< entries.count(); i++)
            {
                success = copy(src + QStringLiteral("/") + entries[i],
                               dst + QStringLiteral("/") + entries[i],
                               recursively);
                if(!success)
                    return false;
            }
        }

        return true;
    }

    return false;
}

bool EnvPrivate::remove(const QString &path)
{
    if(isFile(path)) {
        QFile file(path);
        return file.remove();
    }

    if(isDir(path)) {
        QDir dir(path);
        return dir.removeRecursively();
    }

    return false;
}

QString EnvPrivate::read(const QString &path)
{
    if(!isFile(path)){
        qWarning() << "Qak" << "Env::read" << "could not read file" << path << "Aborting";
        return QString();
    }

    QString source(path);
    source = source.replace("qrc://",":");
    source = source.replace("file://","");

    QFile file(source);
    QString fileContent;
    if ( file.open(QFile::ReadOnly) ) {
        QString line;
        QTextStream t( &file );
        do {
            line = t.readLine();
            fileContent += line;
         } while (!line.isNull());

        file.close();
    } else {
        qWarning() << "Qak" << "Env::read" << "unable to open" << path << "Aborting";
        return QString();
    }
    return fileContent;
}

bool EnvPrivate::write(const QString &data, const QString &path)
{
    return write(data, path, false);
}

bool EnvPrivate::write(const QString &data, const QString &path, bool overwrite)
{
    if(!overwrite && exists(path)) {
        qWarning() << "Qak" << "Env::write" << path << "already exist";
        return false;
    }

    if(overwrite && exists(path)) {
        if(isFile(path)) {
            if(!remove(path)) {
                qWarning() << "Qak" << "Env::write" << "could not remove" << path << "for writing. Aborting";
                return false;
            }
        }

        if(isDir(path)) {
            qWarning() << "Qak" << "Env::write" << path << "is a directory. Not overwriting";
            return false;
        }
    }

    QFile file(path);
    if(!file.open(QFile::WriteOnly | QFile::Truncate)) {
        qWarning() << "Qak" << "Env::write" << path << "could not be opened for writing. Aborting";
        return false;
    }

    QTextStream out(&file);
    out << data;
    file.close();
    return true;
}

QStringList EnvPrivate::list(const QString &dir)
{
    return list(dir, false);
}

QStringList EnvPrivate::list(const QString &dir, bool recursively)
{
    QStringList entryList;

    if(isDir(dir)) {

        QDir sourceDir(dir);

        QStringList entries = sourceDir.entryList(QDir::AllEntries | QDir::NoDotAndDotDot);

        // Files
        for(int i = 0; i< entries.count(); i++) {
            entryList.append(sourceDir.absolutePath() + QStringLiteral("/") + entries[i]);
        }

        if(recursively) {
            // Decent directories
            entries.clear();
            entries = sourceDir.entryList(QDir::AllDirs | QDir::NoDotAndDotDot);
            for(int i = 0; i< entries.count(); i++)
            {
                entryList += list(sourceDir.absolutePath() + QStringLiteral("/") + entries[i], recursively);
            }
        }

        return entryList;
    }

    qWarning() << "Qak" << "Env::list" << dir << "is not a directory";
    return entryList;
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

qint64 EnvPrivate::size(const QString &path)
{
    QFileInfo check(path);
    return check.size();
}

bool EnvPrivate::registerResource(const QString &rccFilename, const QString &resourceRoot)
{
    return QResource::registerResource(rccFilename,resourceRoot);
}

bool EnvPrivate::unregisterResource(const QString &rccFilename, const QString &resourceRoot)
{
    return QResource::unregisterResource(rccFilename,resourceRoot);
}

void EnvPrivate::setLanguage(const QString &languageCode)
{

    /*
     * // https://stackoverflow.com/questions/15355156/is-it-possible-to-change-language-on-qt-at-runtime/48719049#48719049
     */

    //if (translator.load(QLocale(), QLatin1String("myapp"), QLatin1String("_"), QLatin1String(":/translations")))
    //          app.installTranslator(&translator);

    if (!m_translator.isEmpty())
            QCoreApplication::removeTranslator(&m_translator);
    m_translator.load(QStringLiteral(":/translations/non_") + languageCode);
    QCoreApplication::installTranslator(&m_translator);
    QQmlEngine::contextForObject(qApp->topLevelWindows()[0])->engine()->retranslate();

}

Qak::AndroidEnv *EnvPrivate::androidEnv()
{
    return &_androidEnv;
}

Qak::MouseEnv *EnvPrivate::mouseEnv()
{
    return &_mouseEnv;
}

QString EnvPrivate::subEnvPath()
{
    QString sub;
    if(QGuiApplication::organizationName() != "")
        sub += QGuiApplication::organizationName() + QStringLiteral("/");
    if(QGuiApplication::organizationDomain() != "")
        sub += QGuiApplication::organizationDomain() + QStringLiteral("/");
    if(QGuiApplication::applicationName() != "")
        sub += QGuiApplication::applicationName() + QStringLiteral("/");
    #ifdef QAK_STORE_VERSION_PATH
    if(QGuiApplication::applicationVersion() != "")
        sub += QGuiApplication::applicationVersion() + QStringLiteral("/") ;
    #endif
    if(sub == "") {
         qWarning() << "Qak" << "Env" << "Couldn't resolve" << sub << "as a valid path. Using generic directory: \"Qak\"";
         sub = "Qak";
    }

    while(sub.endsWith( QStringLiteral("/") )) sub.chop(1);

    return sub;
}
