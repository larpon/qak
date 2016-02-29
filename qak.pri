QT += qml quick

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH += $$PWD

INCLUDEPATH += \
    $$PWD \
    $$PWD/src

CONFIG += c++11

HEADERS += \
    $$PWD/src/maskedmousearea.h \
    $$PWD/src/resource.h

SOURCES += \
    $$PWD/src/maskedmousearea.cpp \
    $$PWD/src/resource.cpp

RESOURCES += \
    $$PWD/qak.qrc

DISTFILES += \
    $$PWD/README.md
