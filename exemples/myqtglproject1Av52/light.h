/****************************************************************************
** file: light.h
**
**  Declaration of  class Light
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

#ifndef LIGHT_H
#define LIGHT_H

#include <QVector4D>

class Light
{
public:
    Light();

    QVector4D position;
    QVector4D ambient;
    QVector4D diffuse;
    QVector4D specular;
};

#endif // LIGHT_H
