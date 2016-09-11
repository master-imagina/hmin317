QT       += core gui opengl

TARGET = myqtglproject
TEMPLATE = app

SOURCES += main.cpp\
        mainwindow.cpp \
    glwidget.cpp \
    camera.cpp \
    light.cpp \
    material.cpp \
    trackball.cpp

HEADERS  += mainwindow.h \
    glwidget.h \
    camera.h \
    light.h \
    material.h \
    trackball.h

FORMS    += mainwindow.ui

OTHER_FILES += \
    vgouraud.glsl \
    fgouraud.glsl \
    vphong.glsl \
    fphong.glsl \
    vtexture.glsl \
    ftexture.glsl \
    vnormal.glsl \
    fnormal.glsl

RESOURCES += \
    resources.qrc
