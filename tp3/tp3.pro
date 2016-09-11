INCLUDEPATH += $$PWD

QT += network

SOURCES += $$PWD/openglwindow.cpp \
    trianglewindow.cpp

HEADERS += $$PWD/openglwindow.h \
    $$PWD/trianglewindow.h

SOURCES += \
    main.cpp

target.path = $$PWD
INSTALLS += target
QMAKE_MAC_SDK = macosx10.11

RESOURCES += \
    gestionnaire.qrc
