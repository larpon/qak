#include "qak_plugin.h"
#include "maskedmousearea.h"
#include "resources.h"

#include <qqml.h>

void QakPlugin::registerTypes(const char *uri)
{
    // @uri Qak
    qmlRegisterType<MaskedMouseArea>(uri, 1, 0, "MaskedMouseArea");
    qmlRegisterType<Resources>(uri, 1, 0, "Resources");
}

