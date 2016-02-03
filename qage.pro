TEMPLATE = app

QT += qml quick

CONFIG += c++11

SOURCES += main.cpp \
    src/resource.cpp

RESOURCES += qml.qrc \
    qageqml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

DISTFILES +=

HEADERS += \
    src/resource.h
