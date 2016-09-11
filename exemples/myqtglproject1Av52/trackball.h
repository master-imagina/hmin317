/****************************************************************************
** file: trackball.h
**
**  Declaration of  class TrackBall
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

#ifndef TRACKBALL_H
#define TRACKBALL_H

#include <QVector3D>
#include <QQuaternion>
#include <QTime>

#include <cmath>

class TrackBall
{
public:
    TrackBall();
    void mouseMove(const QPointF& p);
    void mousePress(const QPointF& p);
    void mouseRelease(const QPointF& p);
    void resizeViewport(int width, int height);
    QQuaternion getRotation();

private:
    QQuaternion rotation;
    QVector3D axis;
    double velocity;

    QVector3D lastPos3D;
    QTime lastTime;
    bool trackingMouse;

    double viewportWidth;
    double viewportHeight;

    const double rad2deg;

    QVector3D mousePosTo3D(const QPointF& p);
};

#endif
