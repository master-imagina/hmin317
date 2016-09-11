/****************************************************************************
** file: mainwindow.h
**
**  Definition of  class MainWindow
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

#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);
}

MainWindow::~MainWindow()
{
    delete ui;
}
