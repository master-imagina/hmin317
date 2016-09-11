#ifndef TRIANGLEWINDOW_H
#define TRIANGLEWINDOW_H

#include "openglwindow.h"

#include <QKeyEvent>
#include <QFile>
#include <QTimer>

struct point
{
    float x, y ,z;
};

class paramCamera
{
public:
    float rotX = -45.0;
    float rotY = -45.0;
    float ss = 1.0f;
    float anim = 0.0f;

    int etat = 0;
};

class TriangleWindow : public OpenGLWindow
{

Q_OBJECT

public:
    TriangleWindow();
    TriangleWindow(int maj);
    void initialize();
    void render();
    bool event(QEvent *event);

    void keyPressEvent(QKeyEvent *event);

    void displayTriangles();
    void displayLines();
    void displayTrianglesC();
    void displayPoints();
    void displayTrianglesTexture();

    void displayColor(float);

    void loadMap(QString localPath);
    paramCamera* c;

    enum Season {Winter,Spring,Summer,Autumn};

public slots:
    void update_season();

private:
    bool master = false;
    int m_frame;
    QImage m_image;
    point *p;

    int carte=1;
    int maj = 20;

    QTimer *timer;

    int day;
    Season season;

};

#endif // TRIANGLEWINDOW_H
