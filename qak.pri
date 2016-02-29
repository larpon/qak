QT += qml quick

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH += $$PWD

INCLUDEPATH += src

CONFIG += c++11

SOURCES += src/resource.cpp \
    src/maskedmousearea.cpp

RESOURCES += qak.qrc

DISTFILES += README.md

HEADERS += \
    src/resource.h \
    src/maskedmousearea.h
