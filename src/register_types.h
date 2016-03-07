#ifndef REGISTER_TYPES_H
#define REGISTER_TYPES_H

#include <QQmlEngine>
#include <QJSEngine>

#include "resource.h"
#include "maskedmousearea.h"

#include "qqml.h"

/*
// Second, define the singleton type provider function (callback).
static QObject *ResourceQmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);

    Resource *resource = new Resource();
    //QQmlEngine::setObjectOwnership( resources, QQmlEngine::CppOwnership );
    return resource;
}
*/

class RegisterHelper {

public:
    RegisterHelper() {
        qmlRegisterType<MaskedMouseArea>("Qak", 1, 0, "MaskedMouseArea");
        qmlRegisterType<Resource>("Qak", 1, 0, "Resource");
        //qmlRegisterSingletonType<Resource>("Qak", 1, 0, "Resources", ResourceQmlInstance);
    }
};

static RegisterHelper registerHelper;

#endif // REGISTER_TYPES_H
