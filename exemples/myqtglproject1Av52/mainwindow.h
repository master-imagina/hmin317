/****************************************************************************
** file: mainwindow.h
**
**  Declaration of  class MainWindow
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

#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT
    
public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();
    
private:
    Ui::MainWindow *ui;
};

#endif // MAINWINDOW_H
