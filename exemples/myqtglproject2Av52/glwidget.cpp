/****************************************************************************
** file: glwidget.h
**
**  Definition of  class GLWidget
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

#include "glwidget.h"

GLWidget::GLWidget(QWidget *parent) :
    QGLWidget(parent)
{
    vertices = NULL;
    normals = NULL;
    texCoords = NULL;
    tangents = NULL;
    indices = NULL;

    vboVertices = NULL;
    vboNormals = NULL;
    vboTexCoords = NULL;
    vboTangents = NULL;
    vboIndices = NULL;

    shaderProgram = NULL;
    vertexShader = NULL;
    fragmentShader = NULL;
    currentShader = 0;

    zoom = 0.0;

    displayInfoEnabled = true;
    backgroundColor = QColor(0, 0, 0, 255);

    fpsCounter = 0;
}

GLWidget::~GLWidget()
{
    destroyVBOs();
    destroyShaders();
}

void GLWidget::initializeGL()
{
    initializeGLFunctions();

    glEnable(GL_DEPTH_TEST);

    QImage texColor = QImage(":/textures/bricksDiffuse.png");
    QImage texNormal = QImage(":/textures/bricksNormal.png");

    glActiveTexture(GL_TEXTURE0);
    texID[0] = bindTexture(texColor);
    glActiveTexture(GL_TEXTURE1);
    texID[1] = bindTexture(texNormal);

    connect(&timer, SIGNAL(timeout()), this, SLOT(animate()));
    timer.start(0);

    fpsTime.start();
}

void GLWidget::resizeGL(int width, int height)
{    
    glViewport(0, 0, width, height);

    projectionMatrix.setToIdentity();
    projectionMatrix.perspective(60.0,
                                 static_cast<qreal>(width) /
                                 static_cast<qreal>(height), 0.1, 20.0);

    trackBall.resizeViewport(width, height);

    updateGL();
}

void GLWidget::paintGL()
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    if (!vboVertices)
        return;

    modelViewMatrix.setToIdentity();
    modelViewMatrix.lookAt(camera.eye, camera.at, camera.up);
    modelViewMatrix.translate(0, 0, zoom);
    modelViewMatrix.rotate(trackBall.getRotation());
    normalMatrix = modelViewMatrix.normalMatrix();

    shaderProgram->bind();

    QVector4D ambientProduct = light.ambient * material.ambient;
    QVector4D diffuseProduct = light.diffuse * material.diffuse;
    QVector4D specularProduct = light.specular * material.specular;

    shaderProgram->setUniformValue("lightPosition", light.position);
    shaderProgram->setUniformValue("ambientProduct", ambientProduct);
    shaderProgram->setUniformValue("diffuseProduct", diffuseProduct);
    shaderProgram->setUniformValue("specularProduct", specularProduct);
    shaderProgram->setUniformValue(
                "shininess", static_cast<GLfloat>(material.shininess));

    shaderProgram->setUniformValue("modelViewMatrix", modelViewMatrix);
    shaderProgram->setUniformValue("projectionMatrix", projectionMatrix);
    shaderProgram->setUniformValue("normalMatrix", normalMatrix);

    shaderProgram->setUniformValue("texColorMap", 0);
    shaderProgram->setUniformValue("texNormalMap", 1);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texID[0]);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, texID[1]);

    vboVertices->bind();
    shaderProgram->enableAttributeArray("vPosition");
    shaderProgram->setAttributeBuffer("vPosition", GL_FLOAT, 0, 4, 0);

    vboNormals->bind();
    shaderProgram->enableAttributeArray("vNormal");
    shaderProgram->setAttributeBuffer("vNormal", GL_FLOAT, 0, 3, 0);

    vboTexCoords->bind();
    shaderProgram->enableAttributeArray("vTexCoord");
    shaderProgram->setAttributeBuffer("vTexCoord", GL_FLOAT, 0, 2, 0);

    vboTangents->bind();
    shaderProgram->enableAttributeArray("vTangent");
    shaderProgram->setAttributeBuffer("vTangent", GL_FLOAT, 0, 4, 0);

    vboIndices->bind();

    glDrawElements(GL_TRIANGLES, numFaces * 3, GL_UNSIGNED_INT, 0);

    vboIndices->release();
    vboTangents->release();
    vboTexCoords->release();
    vboNormals->release();
    vboVertices->release();

    shaderProgram->release();

    displayInfo();
}

void GLWidget::displayInfo()
{
    if (!displayInfoEnabled)
        return;

    fpsCounter++;

    if (fpsTime.elapsed() > 1000) {
        fps = fpsCounter * 1000.0 / fpsTime.elapsed();
        fpsTime.restart();
        fpsCounter = 0;
    }

    glActiveTexture(GL_TEXTURE0);
    qglColor(QColor(0,0,0));
    renderText(11, 21, QString("FPS: %1").arg(fps));
    qglColor(QColor(255,255,255));
    renderText(10, 20, QString("FPS: %1").arg(fps));
}

void GLWidget::mouseMoveEvent(QMouseEvent *event)
{
    trackBall.mouseMove(event->localPos());
}

void GLWidget::mousePressEvent(QMouseEvent *event)
{
    if (event->button() & Qt::LeftButton)
        trackBall.mousePress(event->localPos());
}

void GLWidget::mouseReleaseEvent(QMouseEvent *event)
{
    if (event->button() == Qt::LeftButton)
        trackBall.mouseRelease(event->localPos());
}

void GLWidget::wheelEvent(QWheelEvent *event)
{
    zoom += 0.001 * event->delta();
}

void GLWidget::keyPressEvent(QKeyEvent *event)
{
    switch(event->key())
    {
    case Qt::Key_0:
        currentShader = 0;
        emit currentShaderChanged(currentShader);
        createShaders();
        updateGL();
        break;
    case Qt::Key_1:
        currentShader = 1;
        emit currentShaderChanged(currentShader);
        createShaders();
        updateGL();
        break;
    case Qt::Key_2:
        currentShader = 2;
        emit currentShaderChanged(currentShader);
        createShaders();
        updateGL();
        break;
    case Qt::Key_3:
        currentShader = 3;
        emit currentShaderChanged(currentShader);
        createShaders();
        updateGL();
        break;
    case Qt::Key_Escape:
        qApp->quit();
    }
}

void GLWidget::animate()
{
    updateGL();
}

void GLWidget::setDisplayInfo(bool enabled)
{
    displayInfoEnabled = enabled;

    updateGL();
}

void GLWidget::setCurrentShader(int index)
{
    currentShader = index;

    createShaders();
    updateGL();
}

void GLWidget::showFileOpenDialog()
{
    QByteArray fileFormat = "off";
    QString fileName;
    fileName = QFileDialog::getOpenFileName(this, "Open File",
                                            QDir::homePath(),
                                            QString("%1 Files (*.%2)")
                                            .arg(QString(fileFormat.toUpper()))
                                            .arg(QString(fileFormat)));
    if (!fileName.isEmpty()) {
         readOFFFile(fileName);

         genNormals();
         genTexCoordsCylinder();
         genTangents();

         createVBOs();
         createShaders();

         updateGL();
    }
}

void GLWidget::readOFFFile(const QString &fileName)
{
    std::ifstream stream;
    stream.open(fileName.toUtf8(), std::ifstream::in);

    if (!stream.is_open()) {
        qWarning("Cannot open file.");
        return;
    }

    std::string line;

    stream >> line;
    stream >> numVertices >> numFaces >> line;

    delete[] vertices;
    vertices = new QVector4D[numVertices];

    delete[] indices;
    indices = new unsigned int[numFaces * 3];

    if (numVertices > 0) {
        double minLim = std::numeric_limits<double>::min();
        double maxLim = std::numeric_limits<double>::max();
        QVector4D max(minLim, minLim, minLim, 1.0);
        QVector4D min(maxLim, maxLim, maxLim, 1.0);

        for (unsigned int i = 0; i < numVertices; i++) {
            double x, y, z;
            stream >> x >> y >> z;
            max.setX(qMax<double>(max.x(), x));
            max.setY(qMax<double>(max.y(), y));
            max.setZ(qMax<double>(max.z(), z));
            min.setX(qMin<double>(min.x(), x));
            min.setY(qMin<double>(min.y(), y));
            min.setZ(qMin<double>(min.z(), z));

            vertices[i] = QVector4D(x, y, z, 1.0);
        }

        QVector4D midpoint = (min + max) * 0.5;
        double invdiag = 1 / (max - min).length();

        for (unsigned int i = 0; i < numVertices; i++) {
            vertices[i] = (vertices[i] - midpoint) * invdiag;
            vertices[i].setW(1);
        }
    }

    for (unsigned int i = 0; i < numFaces; i++) {
        unsigned int a, b, c;
        stream >> line >> a >> b >> c;
        indices[i * 3    ] = a;
        indices[i * 3 + 1] = b;
        indices[i * 3 + 2] = c;
    }

    emit statusBarMessage(QString("Samples %1, Faces %2")
                         .arg(numVertices)
                         .arg(numFaces));

    stream.close();
}

void GLWidget::genNormals()
{
    delete[] normals;
    normals = new QVector3D[numVertices];

    for (unsigned int i = 0; i < numFaces; i++) {
        unsigned int i1 = indices[i * 3    ];
        unsigned int i2 = indices[i * 3 + 1];
        unsigned int i3 = indices[i * 3 + 2];

        QVector3D v1 = vertices[i1].toVector3D();
        QVector3D v2 = vertices[i2].toVector3D();
        QVector3D v3 = vertices[i3].toVector3D();

        QVector3D faceNormal = QVector3D::crossProduct(v2 - v1, v3 - v1);
        normals[i1] += faceNormal;
        normals[i2] += faceNormal;
        normals[i3] += faceNormal;
    }

    for (unsigned int i = 0; i < numVertices; i++)
        normals[i].normalize();
}

void GLWidget::genTexCoordsCylinder()
{
    delete[] texCoords;
    texCoords = new QVector2D[numVertices];

    double minLim = std::numeric_limits<double>::min();
    double maxLim = std::numeric_limits<double>::max();
    QVector2D max(minLim, minLim);
    QVector2D min(maxLim, maxLim);

    for (unsigned int i = 0; i < numVertices; i++) {
        QVector2D pos = vertices[i].toVector2D();
        max.setX(qMax(max.x(), pos.x()));
        max.setY(qMax(max.y(), pos.y()));
        min.setX(qMin(min.x(), pos.x()));
        min.setY(qMin(min.y(), pos.y()));
    }

    QVector2D size = max - min;
    for (unsigned int i = 0; i < numVertices; i++) {
        double x = 2.0 * (vertices[i].x() - min.x()) / size.x() - 1.0;
        texCoords[i] = QVector2D(acos(x) / M_PI,
                                 (vertices[i].y() - min.y()) / size.y());
    }
}

void GLWidget::genTangents()
{
    delete[] tangents;

    tangents = new QVector4D[numVertices];
    QVector3D *bitangents = new QVector3D[numVertices];

    for (unsigned int i = 0; i < numFaces; i++) {
        unsigned int i1 = indices[i * 3    ];
        unsigned int i2 = indices[i * 3 + 1];
        unsigned int i3 = indices[i * 3 + 2];

        QVector3D E = vertices[i1].toVector3D();
        QVector3D F = vertices[i2].toVector3D();
        QVector3D G = vertices[i3].toVector3D();

        QVector2D stE = texCoords[i1];
        QVector2D stF = texCoords[i2];
        QVector2D stG = texCoords[i3];

        QVector3D P = F - E;
        QVector3D Q = G - E;

        QVector2D st1 = stF - stE;
        QVector2D st2 = stG - stE;

        QMatrix2x2 M;
        M(0,0) =  st2.y(); M(0,1) = -st1.y();
        M(1,0) = -st2.x(); M(1,1) =  st1.x();
        M *= (1.0 / (st1.x()*st2.y() - st2.x()*st1.y()));

        QVector4D T = QVector4D(M(0,0)*P.x() + M(0,1)*Q.x(),
                                M(0,0)*P.y() + M(0,1)*Q.y(),
                                M(0,0)*P.z() + M(0,1)*Q.z(), 0.0);

        QVector3D B = QVector3D(M(1,0)*P.x() + M(1,1)*Q.x(),
                                M(1,0)*P.y() + M(1,1)*Q.y(),
                                M(1,0)*P.z() + M(1,1)*Q.z());

        tangents[i1] += T;
        tangents[i2] += T;
        tangents[i3] += T;

        bitangents[i1] += B;
        bitangents[i2] += B;
        bitangents[i3] += B;
    }

    for (unsigned int i = 0; i < numVertices; i++) {
        const QVector3D& n = normals[i];
        const QVector4D& t = tangents[i];

        tangents[i] = (t - n *
                       QVector3D::dotProduct(n, t.toVector3D())).normalized();

        QVector3D b = QVector3D::crossProduct(n, t.toVector3D());
        double hand = QVector3D::dotProduct(b, bitangents[i]);
        tangents[i].setW((hand < 0.0) ? -1.0 : 1.0);
    }

    delete[] bitangents;
}

void GLWidget::createVBOs()
{
    destroyVBOs();

    vboVertices = new QGLBuffer(QGLBuffer::VertexBuffer);
    vboVertices->create();
    vboVertices->bind();
    vboVertices->setUsagePattern(QGLBuffer::StaticDraw);
    vboVertices->allocate(vertices, numVertices * sizeof(QVector4D));
    delete[] vertices;
    vertices = NULL;

    vboNormals = new QGLBuffer(QGLBuffer::VertexBuffer);
    vboNormals->create();
    vboNormals->bind();
    vboNormals->setUsagePattern(QGLBuffer::StaticDraw);
    vboNormals->allocate(normals, numVertices * sizeof(QVector3D));
    delete[] normals;
    normals = NULL;

    vboTexCoords = new QGLBuffer(QGLBuffer::VertexBuffer);
    vboTexCoords->create();
    vboTexCoords->bind();
    vboTexCoords->setUsagePattern(QGLBuffer::StaticDraw);
    vboTexCoords->allocate(texCoords, numVertices * sizeof(QVector2D));
    delete[] texCoords;
    texCoords = NULL;

    vboTangents = new QGLBuffer(QGLBuffer::VertexBuffer);
    vboTangents->create();
    vboTangents->bind();
    vboTangents->setUsagePattern(QGLBuffer::StaticDraw);
    vboTangents->allocate(tangents, numVertices * sizeof(QVector4D));
    delete[] tangents;
    tangents = NULL;

    vboIndices = new QGLBuffer(QGLBuffer::IndexBuffer);
    vboIndices->create();
    vboIndices->bind();
    vboIndices->setUsagePattern(QGLBuffer::StaticDraw);
    vboIndices->allocate(indices, numFaces * 3 * sizeof(unsigned int));
    delete[] indices;
    indices = NULL;
}

void GLWidget::destroyVBOs()
{
    if (vboVertices) {
        vboVertices->release();
        delete vboVertices;
        vboVertices = NULL;
    }

    if (vboNormals) {
        vboNormals->release();
        delete vboNormals;
        vboNormals = NULL;
    }

    if (vboTexCoords) {
        vboTexCoords->release();
        delete vboTexCoords;
        vboTexCoords = NULL;
    }

    if (vboTangents) {
        vboTangents->release();
        delete vboTangents;
        vboTangents = NULL;
    }

    if (vboIndices) {
        vboIndices->release();
        delete vboIndices;
        vboIndices = NULL;
    }
}

void GLWidget::createShaders()
{
    destroyShaders();

    QString vertexShaderFile[] = {
        ":/shaders/vgouraud.glsl",
        ":/shaders/vphong.glsl",
        ":/shaders/vtexture.glsl",
        ":/shaders/vnormal.glsl"
    };
    QString fragmentShaderFile[] = {
        ":/shaders/fgouraud.glsl",
        ":/shaders/fphong.glsl",
        ":/shaders/ftexture.glsl",
        ":/shaders/fnormal.glsl"
    };

    vertexShader = new QGLShader(QGLShader::Vertex);
    if (!vertexShader->compileSourceFile(vertexShaderFile[currentShader]))
        qWarning() << vertexShader->log();

    fragmentShader = new QGLShader(QGLShader::Fragment);
    if (!fragmentShader->compileSourceFile(fragmentShaderFile[currentShader]))
        qWarning() << fragmentShader->log();

    shaderProgram = new QGLShaderProgram;
    shaderProgram->addShader(vertexShader);
    shaderProgram->addShader(fragmentShader);

    if (!shaderProgram->link())
        qWarning() << shaderProgram->log() << endl;
}

void GLWidget::destroyShaders()
{       
    delete vertexShader;
    vertexShader = NULL;

    delete fragmentShader;
    fragmentShader = NULL;

    if (shaderProgram) {
        shaderProgram->release();
        delete shaderProgram;
        shaderProgram = NULL;
    }
}

void GLWidget::takeScreenshot()
{
    QImage screenshot = grabFrameBuffer();

    QString fileName;
    fileName = QFileDialog::getSaveFileName(this, "Save File As",
                                            QDir::homePath(),
                                            QString("PNG Files (*.png)"));
    if (fileName.length()) {
        if (!fileName.contains(".png"))
            fileName += ".png";
        if (screenshot.save(fileName, "PNG")) {
            QMessageBox::information(this, "Screenshot",
                                     "Screenshot taken!",
                                     QMessageBox::Ok);
        }
    }
}

void GLWidget::setBackgroundColor()
{
    QColorDialog colorDialog;
    backgroundColor = colorDialog.getColor(backgroundColor, this);

    glClearColor(backgroundColor.redF(),
                 backgroundColor.greenF(),
                 backgroundColor.blueF(), 1.0);

    updateGL();
}

void GLWidget::setShininess(int value)
{
    material.shininess = exp(static_cast<double>(value) / 200.0);

    updateGL();
}

void GLWidget::setLightDiffuseRed(int value)
{
    material.diffuse.setX(value / 255.0);

    updateGL();
}

void GLWidget::setLightDiffuseGreen(int value)
{
    material.diffuse.setY(value / 255.0);

    updateGL();
}

void GLWidget::setLightDiffuseBlue(int value)
{
    material.diffuse.setZ(value / 255.0);

    updateGL();
}
