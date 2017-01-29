#include "qak_plugin.h"
#include "maskedmousearea.h"
#include "propertytoggle.h"
#include "resource.h"
#include "store.h"

#include <qqml.h>

void QakPlugin::registerTypes(const char *uri)
{
    // @uri Qak
    qmlRegisterType<MaskedMouseArea>(uri, 1, 0, "MaskedMouseArea");
    qmlRegisterType<Resource>(uri, 1, 0, "Resource");
    qmlRegisterType<Store>(uri, 1, 0, "Store");
    qmlRegisterType<PropertyToggle>(uri, 1, 0, "PropertyToggle");
}

