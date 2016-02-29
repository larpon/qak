#include "qak_plugin.h"
#include "maskedmousearea.h"
#include "resource.h"

#include <qqml.h>

void QakPlugin::registerTypes(const char *uri)
{
    // @uri Qak
    qmlRegisterType<MaskedMouseArea>(uri, 1, 0, "MaskedMouseArea");
    qmlRegisterType<Resource>(uri, 1, 0, "Resource");
}

