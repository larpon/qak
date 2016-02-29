QT += qml quick

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH += $$PWD

INCLUDEPATH += \
    $$PWD \
    $$PWD/src

CONFIG += c++11

SOURCES += \
    $$PWD/src/maskedmousearea.cpp

RESOURCES += \
    $$PWD/qak.qrc

DISTFILES += \
    $$PWD/README.md

HEADERS += \
    $$PWD/src/maskedmousearea.h
