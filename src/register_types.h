#ifndef REGISTER_TYPES_H
#define REGISTER_TYPES_H

#include <QQmlEngine>
#include <QJSEngine>

#include "resources.h"
#include "maskedmousearea.h"

#include "qqml.h"

// Second, define the singleton type provider function (callback).
static QObject *ResourcesQmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);

    Resources *resources = new Resources();
    //QQmlEngine::setObjectOwnership( resources, QQmlEngine::CppOwnership );
    return resources;
}

class RegisterHelper {

public:
    RegisterHelper() {
        qmlRegisterType<MaskedMouseArea>("Qak", 1, 0, "MaskedMouseArea");
        qmlRegisterSingletonType<Resources>("Qak", 1, 0, "Resources", ResourcesQmlInstance);
    }
};

static RegisterHelper resourcesRegisterHelper;

#endif // REGISTER_TYPES_H
