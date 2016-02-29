#ifndef QAK_PLUGIN_H
#define QAK_PLUGIN_H

#include <QQmlExtensionPlugin>

class QakPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "Qak")

public:
    void registerTypes(const char *uri);
};

#endif // QAK_PLUGIN_H
