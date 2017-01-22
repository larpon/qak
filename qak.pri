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
    $$PWD/src/resource.h \
    $$PWD/src/store.h \
    $$PWD/src/qak_plugin.h \
    $$PWD/src/itemtoggle.h

SOURCES += \
    $$PWD/src/maskedmousearea.cpp \
    $$PWD/src/resource.cpp \
    $$PWD/src/store.cpp \
    $$PWD/src/qak_plugin.cpp \
    $$PWD/src/itemtoggle.cpp

RESOURCES += \
    $$PWD/qak.qrc

DISTFILES += \
    $$PWD/README.md \
    $$PWD/LICENSE

exists(.git) {
    unix {
        GIT_BRANCH_NAME = $$system(git rev-parse --abbrev-ref HEAD)
        message("Qak branch $$GIT_BRANCH_NAME")
    }
}
