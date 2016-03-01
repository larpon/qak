QT += qml

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH += $$PWD

INCLUDEPATH += \
    $$PWD \
    $$PWD/src

HEADERS += \
    $$PWD/src/maskedmousearea.h \
    $$PWD/src/resources.h \
    $$PWD/src/register_types.h

SOURCES += \
    $$PWD/src/maskedmousearea.cpp \
    $$PWD/src/resources.cpp

RESOURCES += \
    $$PWD/qak.qrc

DISTFILES += \
    $$PWD/README.md
