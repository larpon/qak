#ifndef REGISTER_QAK_H
#define REGISTER_QAK_H

#include <QtCore/QCoreApplication>
#include <QtQml/QQmlEngine>

#include "qqml.h"

#include "src/store.h"
#include "src/resource.h"
#include "src/propertytoggle.h"
#include "src/itemanimationprivate.h"
#include "src/maskedmousearea.h"

static void registerQak() {
        qmlRegisterType<MaskedMouseArea>("Qak", 1, 0, "MaskedMouseArea");
        qmlRegisterType<Resource>("Qak", 1, 0, "Resource");
        qmlRegisterType<Store>("Qak", 1, 0, "Store");

        qmlRegisterType<PropertyToggle>("Qak", 1, 0, "PropertyToggle");
        qmlRegisterType<ItemAnimationPrivate>("Qak.Private", 1, 0, "ItemAnimationPrivate");
        //qmlRegisterSingletonType<Resource>("Qak", 1, 0, "Resources", ResourceQmlInstance);
}

Q_COREAPP_STARTUP_FUNCTION(registerQak)

#endif // REGISTER_QAK_H
