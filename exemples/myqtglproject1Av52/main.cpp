/****************************************************************************
** file: main.cpp
**
**  Definition of   main function
**
** Authors: João Paulo Gois & Harlen C. Batagelo
**
** How to cite this work:
**
@inproceedings{jpgois2012sib,
author = {Jo\~ao Paulo Gois and Harlen C. Batagelo},
title = {Interactive Graphics Applications with OpenGL Shading  Language and Qt},
booktitle={Graphics, Patterns and Images Tutorials (SIBGRAPI-T), 2012 25th SIBGRAPI Conference on},
year = {2012},
isbn = {XX},
pages = {XX},
doi = {XX},
}
**
**********************************************************************/

#include <QApplication>
#include <QGLFormat>

#include "mainwindow.h"

int main(int argc, char *argv[])
{
    QGLFormat format = QGLFormat::defaultFormat();

    format.setVersion(  QGLFormat::OpenGL_Version_4_0, QGLFormat::OpenGL_Version_3_3);
     format.setSwapInterval(0);
    format.setSampleBuffers(true);
    format.setSamples(8);
    if (!format.sampleBuffers())
        qWarning("Multisample buffer is not supported.");
    QGLFormat::setDefaultFormat(format);

    QApplication a(argc, argv);
    MainWindow w;
    w.show();
    
    return a.exec();
}
