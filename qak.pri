QT += qml quick multimedia
!no_desktop: QT += widgets

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH += $$PWD

INCLUDEPATH += \
    $$PWD \
    $$PWD/src

HEADERS += \
    $$PWD/qak.h \
    $$PWD/src/maskedmousearea.h \
    $$PWD/src/resource.h

SOURCES += \
    $$PWD/src/maskedmousearea.cpp \
    $$PWD/src/resource.cpp

RESOURCES += \
    $$PWD/qak.qrc

DISTFILES += \
    $$PWD/README.md \
    $$PWD/LICENSE
