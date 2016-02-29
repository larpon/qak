#include "qak_plugin.h"
#include "maskedmousearea.h"

#include <qqml.h>

void QakPlugin::registerTypes(const char *uri)
{
    // @uri org.qak.qt.qmlplugins
    qmlRegisterType<MaskedMouseArea>(uri, 1, 0, "MaskedMouseArea");
}

