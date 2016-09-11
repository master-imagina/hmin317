#include "trianglewindow.h"

#include <QtGui/QGuiApplication>
#include <QtGui/QMatrix4x4>
#include <QtGui/QOpenGLShaderProgram>
#include <QtGui/QScreen>

#include <QtCore/qmath.h>
#include <QMouseEvent>
#include <QKeyEvent>
#include <time.h>
#include <sys/time.h>
#include <iostream>

#include <QtCore>
#include <QtGui>
using namespace std;

#include <calendar.h>
#include <seasonclient.h>
#include <seasonserver.h>


int main(int argc, char **argv)
{
    srand(time(NULL));
    QGuiApplication app(argc, argv);

    QSurfaceFormat format;
    format.setSamples(16);

    paramCamera* c=new paramCamera();

    TriangleWindow window;
    window.c = c;
    window.setFormat(format);
    window.resize(500,375);
    window.setPosition(0,0);
    window.show();

    TriangleWindow window2(100);
    window2.c = c;
    window2.setFormat(format);
    window2.resize(500,375);
    window2.setPosition(500, 0);
    window2.show();

    TriangleWindow window3(500);
    window3.c = c;
    window3.setFormat(format);
    window3.resize(500,375);
    window3.setPosition(0, 450);
    window3.show();

    TriangleWindow window4(1000);
    window4.c = c;
    window4.setFormat(format);
    window4.resize(500,375);
    window4.setPosition(500,450);
    window4.show();

    QTimer *calendar = new QTimer;

    return app.exec();
}

