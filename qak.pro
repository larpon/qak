TEMPLATE = lib

TARGET = qak

QT += qml quick widgets androidextras

CONFIG += qt plugin c++11

QML_IMPORT_PATH = $$PWD

TARGET = $$qtLibraryTarget($$TARGET)
uri = Qak

# Input
SOURCES += \
    src/qak_plugin.cpp \
    src/maskedmousearea.cpp \
    src/resource.cpp

HEADERS += \
    src/qak_plugin.h \
    src/maskedmousearea.h \
    src/resource.h

DISTFILES = qmldir \
    qak.pri \
    README.md \
    LICENSE

!equals(_PRO_FILE_PWD_, $$OUT_PWD) {
    copy_qmldir.target = $$OUT_PWD/qmldir
    copy_qmldir.depends = $$_PRO_FILE_PWD_/qmldir
    copy_qmldir.commands = $(COPY_FILE) \"$$replace(copy_qmldir.depends, /, $$QMAKE_DIR_SEP)\" \"$$replace(copy_qmldir.target, /, $$QMAKE_DIR_SEP)\"
    QMAKE_EXTRA_TARGETS += copy_qmldir
    PRE_TARGETDEPS += $$copy_qmldir.target
}

qmldir.files = qmldir
unix {
    installPath = $$[QT_INSTALL_QML]/$$replace(uri, \\., /)
    qmldir.path = $$installPath
    target.path = $$installPath
    INSTALLS += target qmldir
}

RESOURCES += \
    qak.qrc
