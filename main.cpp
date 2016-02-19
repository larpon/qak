//#include "src/platform.h"
//#include "src/store.h"

#include "src/resource.h"
#include "src/maskedmousearea.h"

//#include "src/fileio.h"

//#include <QtQml>
#include <QQmlContext>
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlApplicationEngine>

int main(int argc, char *argv[])
{

    // Register custom QML types - this must be done before running the qml in which it's used
    //qmlRegisterType<Platform, 1>("Platform", 1, 0, "Platform");
    //qmlRegisterType<Store, 1>("Store", 1, 0, "Store");
    //qmlRegisterType<Resource, 1>("Resource", 1, 0, "Resource");
    //qmlRegisterType<FileIO, 1>("FileIO", 1, 0, "FileIO");

    qmlRegisterType<MaskedMouseArea>("QakQuick", 1, 0, "MaskedMouseArea");

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    #ifdef QT_DEBUG
        engine.rootContext()->setContextProperty("debugBuild", QVariant(true));
    #else
        engine.rootContext()->setContextProperty("debugBuild", QVariant(false));
    #endif

    Resource resource;
    engine.rootContext()->setContextProperty("resource", &resource);

    // Specific to this project to add QML modules from the "modules" directory
    engine.addImportPath("qrc:///modules/");

    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    return app.exec();
}
