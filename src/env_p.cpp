#include "env_p.h"

EnvPrivate::EnvPrivate(QObject *parent) : QObject(parent)
{

}

QString EnvPrivate::config()
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
         qWarning() << "Store warning: Couldn't resolve" << sub << "for storing values. Using generic directory: \"Qak\"";
         sub = "Qak";
    }

    while(sub.endsWith( QDir::separator() )) sub.chop(1);

    return QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)+QDir::separator()+sub;

}
