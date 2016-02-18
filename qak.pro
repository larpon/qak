TEMPLATE = app

QT += qml quick

CONFIG += c++11

SOURCES += main.cpp \
    src/resource.cpp \
    src/maskedmousearea.cpp

RESOURCES += qml.qrc \
    qakqml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

DISTFILES +=

HEADERS += \
    src/resource.h \
    src/maskedmousearea.h
