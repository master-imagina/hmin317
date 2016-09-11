/****************************************************************************
** file: material.cpp
**
**  Definition of  class Material
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

#include <cmath>

#include "material.h"

Material::Material()
{
    ambient = QVector4D(1.0, 1.0, 1.0, 1.0);
    diffuse = QVector4D(0.6, 0.6, 0.6, 1.0);
    specular = QVector4D(0.4, 0.4, 0.4, 1.0);
    shininess = exp(2.5);
}
