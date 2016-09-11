/****************************************************************************
** file: light.h
**
**  Definition of  class Light
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

#include "light.h"

Light::Light()
{
    position = QVector4D(3.0, 3.0, 3.0, 0.0);
    ambient = QVector4D(0.1, 0.1, 0.1, 1.0);
    diffuse = QVector4D(0.9, 0.9, 0.9, 1.0);
    specular = QVector4D(0.9, 0.9, 0.9, 1.0);
}
