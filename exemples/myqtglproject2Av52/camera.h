/****************************************************************************
** file: camera.h
**
**  Declaration of  class Camera
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

#ifndef CAMERA_H
#define CAMERA_H

#include <QVector3D>

class Camera
{
public:
    Camera();

    QVector3D eye;
    QVector3D at;
    QVector3D up;
};

#endif // CAMERA_H
