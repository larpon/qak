#ifndef REGISTER_QAK_H
#define REGISTER_QAK_H

#include <QtCore/QCoreApplication>
#include <QtQml/QQmlEngine>

#include "qqml.h"

#include "src/aid_p.h"
#include "src/env_p.h"
#include "src/shutdowncheck.h"
#include "src/store.h"
#include "src/resource.h"
#include "src/propertytoggle.h"
#include "src/itemanimation_p.h"
#include "src/mouserotate_p.h"
#include "src/maskedmousearea.h"

static void qmlRegisterTypesQak() {
    qmlRegisterType<MaskedMouseArea>("Qak", 1, 0, "MaskedMouseArea");
    qmlRegisterType<Resource>("Qak", 1, 0, "Resource");
    qmlRegisterType<Store>("Qak", 1, 0, "Store");

    qmlRegisterType<PropertyToggle>("Qak", 1, 0, "PropertyToggle");

    qmlRegisterType<AidPrivate>("Qak.Private", 1, 0, "AidPrivate");
    qmlRegisterType<ItemAnimationPrivate>("Qak.Private", 1, 0, "ItemAnimationPrivate");
    qmlRegisterType<MouseRotatePrivate>("Qak.Private", 1, 0, "MouseRotatePrivate");
    qmlRegisterType<EnvPrivate>("Qak.Private", 1, 0, "EnvPrivate");

    qmlRegisterType<ShutdownCheck>("Qak", 1, 0, "ShutdownCheck");
    //qmlRegisterSingletonType<Resource>("Qak", 1, 0, "Resources", ResourceQmlInstance);
}

Q_COREAPP_STARTUP_FUNCTION(qmlRegisterTypesQak)

#endif // REGISTER_QAK_H
