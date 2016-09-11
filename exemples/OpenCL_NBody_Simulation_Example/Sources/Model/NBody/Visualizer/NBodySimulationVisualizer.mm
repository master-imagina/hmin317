/*
     File: NBodySimulationVisualizer.mm
 Abstract: n/a
  Version: 3.5
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 
 */

#pragma mark -
#pragma mark Private - Headers

#import <cmath>
#import <iostream>

#import <OpenGL/gl.h>

#import "GLMConstants.h"
#import "GLMSizes.h"

#import "GLMTransforms.h"

#import "GLUProgram.h"
#import "GLUTexture.h"

#import "NBodyConstants.h"

#import "NBodySimulationVisualizer.h"

#pragma mark -
#pragma mark Private - Namespace

using namespace NBody::Simulation;

#pragma mark -
#pragma mark Private - Enumerated Types

enum NBodyVisualizerFlags
{
    eNBodyIsAcquired = 0,
    eNBodyIsResetting,
    eNBodyIsRotating,
    eNBodyIsEarthView
};

typedef enum NBodyVisualizerFlags NBodyVisualizerFlags;

enum NBodyVisualizerProperties
{
    eNBodyStarSize = 0,
    eNBodyStarScale,
    eNBodyTimeScale,
    eNBodyRotationSpeed,
    eNBodyRotationDelta,
    eNBodyViewTime,
    eNBodyViewZoom,
    eNBodyViewDistance,
    eNBodyViewZoomSpeed
};

typedef enum NBodyVisualizerProperties NBodyVisualizerProperties;

enum NBodyVisualizerGraphics
{
    eNBodyBufferID = 0,
    eNBodyBufferCount,
    eNBodyBufferSize,
    eNBodyLocSampler2D,
    eNBodyLocPointSize
};

typedef enum NBodyVisualizerGraphics NBodyVisualizerGraphics;

#pragma mark -
#pragma mark Private - Utilities - Properties

void Visualizer::advance(const GLuint& nDemo)
{
    if(nDemo < mnCount)
    {
        const GLfloat t = std::sinf(m_Property[eNBodyViewTime]);
        const GLfloat T = 1.0f - t;
        
        m_Property[eNBodyViewDistance] = t * mpProperties[nDemo].mnViewDistance + T * m_Property[eNBodyViewZoom];
        
        m_Rotation.x = t * mpProperties[nDemo].mnRotateX + T * m_ViewRotation.x;
        m_Rotation.y = t * mpProperties[nDemo].mnRotateY + T * m_ViewRotation.y;
    } // if
} // advance

#pragma mark -
#pragma mark Private - Utilities - Transformations

#import "GLMTransforms.h"

void Visualizer::projection()
{
    glMatrixMode(GL_PROJECTION);
    
    // DEPRECATED gluPerspective():
    //
    //    glLoadIdentity();
    //    gluPerspective(60, (GLfloat)mnWidth / (GLfloat)mnHeight, 0.1, 10000);
    
    simd::float4x4 proj = GLM::projection(60, m_Frame.width, m_Frame.height, 1.0f, 10000);
    
    GLM::load(true, proj);
} // projection

void Visualizer::lookAt(const GLfloat *pPosition)
{
    glMatrixMode(GL_MODELVIEW);
    
    // DEPRECATED gluLookAt():
    //
    //    glLoadIdentity();
    //
    //    if(mnActiveDemo == 0 && m_Flag[eNBodyIsEarthView])
    //    {
    //        GLfloat *pEye = pPosition + 3472;
    //        gluLookAt(pEye[0], pEye[1], pEye[2], 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
    //    }
    //    else
    //    {
    //        gluLookAt(-m_Property[eNBodyViewDistance], 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
    //    }
    
    simd::float3 eye    = 0.0f;
    simd::float3 center = {0.0f, 0.0f, 0.0f};
    simd::float3 up     = {0.0f, 1.0f, 0.0f};
    
    if((mnActiveDemo == 0) && m_Flag[eNBodyIsEarthView])
    {
        const GLfloat *pEye = pPosition + 3472;
        
        eye = {pEye[0], pEye[1], pEye[2]};
    } // if
    else
    {
        eye = {-m_Property[eNBodyViewDistance], 0.0f, 0.0f};
    } // else
    
    simd::float4x4 mv = GLM::lookAt(eye, center, up);
    
    GLM::load(false, mv);
} // lookAt

#pragma mark -
#pragma mark Private - Utilities - Updating

void Visualizer::update()
{
    if((m_Rotation.x > 180) || (m_Rotation.y > 180))
    {
        while(m_Rotation.x > 180)
        {
            m_Rotation.x -= 360;
        } // while
        
        while(m_Rotation.y > 180)
        {
            m_Rotation.y -= 360;
        } // while
    } // if
    
    if((m_Rotation.x < -180) || (m_Rotation.y < -180))
    {
        while(m_Rotation.x < -180)
        {
            m_Rotation.x += 360;
        } // while
        
        while(m_Rotation.y < -180)
        {
            m_Rotation.y += 360;
        } // while
    } // if
    
    if(m_Flag[eNBodyIsRotating])
    {
        // (cos(0 to pi) + 1) * 0.5f
        m_Property[eNBodyRotationSpeed] += m_Property[eNBodyRotationDelta];
        
        if(m_Property[eNBodyRotationSpeed] > GLM::kPi_f)
        {
            m_Property[eNBodyRotationSpeed] = GLM::kPi_f;
        } // if
    } // if
    else
    {
        m_Property[eNBodyRotationSpeed] -= m_Property[eNBodyRotationDelta];
        
        if(m_Property[eNBodyRotationSpeed] < 0.0f)
        {
            m_Property[eNBodyRotationSpeed] = 0.0f;
        } // if
    } // else
    
    if (m_Flag[eNBodyIsResetting])
    {
        m_Property[eNBodyViewTime] += 0.02;
        
        if(m_Property[eNBodyViewTime] >= GLM::kHalfPi_f)
        {
            m_Property[eNBodyRotationSpeed] = 0.0f;
            
            reset(mnActiveDemo);
            
            m_Flag[eNBodyIsResetting] = false;
        } // if
        else
        {
            advance(mnActiveDemo);
        } // else
    } // if
} // update

#pragma mark -
#pragma mark Private - Utilities - Rendering

void Visualizer::render(const GLfloat *pPosition)
{
    glViewport(0, 0, m_Bounds[0], m_Bounds[1]);
    
    glBlendFunc(GL_ONE, GL_ONE);
    glEnable(GL_BLEND);
    {
        mpProgram->enable();
        {
            glActiveTexture(GL_TEXTURE0);
            
            glEnableClientState(GL_VERTEX_ARRAY);
            {
                glBindBuffer(GL_ARRAY_BUFFER, m_Graphic[eNBodyBufferID]);
                {
                    glBufferSubData(GL_ARRAY_BUFFER, 0, m_Graphic[eNBodyBufferSize], pPosition);
                    glVertexPointer(4, GL_FLOAT, 0, 0);
                }
                glBindBuffer(GL_ARRAY_BUFFER, 0);
                
                glPushMatrix();
                {
                    if(!m_Flag[eNBodyIsResetting])
                    {
                        const GLfloat rotFactor = 1.0f - 0.5f * (1.0f + std::cosf(m_Property[eNBodyRotationSpeed]));
                        
                        m_Rotation.x += 1.6f * m_Property[eNBodyTimeScale] * rotFactor;
                        m_Rotation.y += 0.8f * m_Property[eNBodyTimeScale] * rotFactor;
                    } // if
                    
                    if((mnActiveDemo != 0) || !m_Flag[eNBodyIsEarthView])
                    {
                        glRotatef(m_Rotation.y, 1, 0, 0);
                        glRotatef(m_Rotation.x, 0, 1, 0);
                    } // if
                    
                    glUniform1f(m_Graphic[eNBodyLocPointSize],
                                m_Property[eNBodyStarSize] * mpProperties[mnActiveDemo].mnPointSize);
                    
                    mpTexture->enable();
                    
                    // white stars
                    glColor3f(0.8, 0.8, 0.8);
                    glDrawArrays(GL_POINTS, 0, m_Graphic[eNBodyBufferCount] / 8);
                    
                    // blue stars
                    glColor3f(0.4, 0.6, 1.0);
                    glDrawArrays(GL_POINTS, m_Graphic[eNBodyBufferCount] / 8, m_Graphic[eNBodyBufferCount] / 4);
                    
                    // red stars
                    glColor3f(1.0, 0.6, 0.6);
                    glDrawArrays(GL_POINTS, m_Graphic[eNBodyBufferCount] / 12, m_Graphic[eNBodyBufferCount] / 4);
                    
                    mpGausssian->enable();
                    
                    if(mnActiveDemo != 0)
                    {
                        glUniform1f(m_Graphic[eNBodyLocPointSize],
                                    300.f * mpProperties[mnActiveDemo].mnPointSize);
                        
                        // purple clouds
                        glColor3f(0.032f, 0.01f, 0.026f);
                        glDrawArrays(GL_POINTS, 0, 64);
                        
                        // blue clouds
                        glColor3f(0.018f, 0.01f, 0.032f);
                        glDrawArrays(GL_POINTS, 64, 64);
                    } // if
                    else
                    {
                        glUniform1f(m_Graphic[eNBodyLocPointSize], 300.f);
                        
                        GLuint step = m_Graphic[eNBodyBufferCount] / 24;
                        
                        // pink
                        glColor3f(0.04f, 0.015f, 0.025f);
                        
                        GLuint i;
                        
                        for( i = 0; i < m_Graphic[eNBodyBufferCount] / 84; i += step )
                        {
                            glDrawArrays( GL_POINTS, i, 1 );
                        } // for
                        
                        // blue
                        glColor3f(0.04f, 0.001f, 0.08f);
                        
                        for( i = 64; i < m_Graphic[eNBodyBufferCount] / 84; i += step )
                        {
                            glDrawArrays( GL_POINTS, i, 1 );
                        } // for
                    } // else
                    
                    glBindTexture(GL_TEXTURE_2D, 0);
                    
                    glColor3f(1.0f, 1.0f, 1.0f);
                }
                glPopMatrix();
            }
            glDisableClientState(GL_VERTEX_ARRAY);
        }
        mpProgram->disable();
    }
    glDisable(GL_BLEND);
} // render

#pragma mark -
#pragma mark Private - Utilities - Assets

bool Visualizer::buffer(const GLuint& nCount)
{
    m_Graphic[eNBodyBufferID]    = 0;
    m_Graphic[eNBodyBufferCount] = nCount;
    m_Graphic[eNBodyBufferSize]  = 4 * m_Graphic[eNBodyBufferCount] * GLM::Size::kFloat;
    
    glEnableClientState(GL_VERTEX_ARRAY);
    {
        glGenBuffers(1, &m_Graphic[eNBodyBufferID]);
        
        if(m_Graphic[eNBodyBufferID])
        {
            glBindBuffer(GL_ARRAY_BUFFER, m_Graphic[eNBodyBufferID]);
            {
                glBufferData(GL_ARRAY_BUFFER, m_Graphic[eNBodyBufferSize], nullptr, GL_DYNAMIC_DRAW_ARB);
                glVertexPointer(4, GL_FLOAT, 0, 0);
            }
            glBindBuffer(GL_ARRAY_BUFFER, 0);
        } // if
    }
    glDisableClientState(GL_VERTEX_ARRAY);
    
    return bool(m_Graphic[eNBodyBufferID]);
} // buffer

bool Visualizer::textures(CFStringRef  pName,
                          CFStringRef  pExt,
                          const GLint& texRes)
{
    try
    {
        mpTexture = new GLU::Texture(pName, pExt);
    } // try
    catch(std::bad_alloc& ba)
    {
        NSLog(@">> ERROR: Failed creating a backing-store copy for 2D texture: \"%s\"", ba.what());
        
        return false;
    } // catch
    
    try
    {
        mpGausssian = new GLU::Gaussian(texRes);
    } // try
    catch(std::bad_alloc& ba)
    {
        NSLog(@">> ERROR: Failed creating a backing-store copy for the Guassian texture: \"%s\"", ba.what());
        
        return false;
    } // catch
    
    return mpTexture->texture() && mpGausssian->texture();
} // textures

bool Visualizer::program(CFStringRef pName)
{
    try
    {
        mpProgram = new GLU::Program(pName, GL_POINTS, GL_TRIANGLE_STRIP, 4);
    } // try
    catch(std::bad_alloc& ba)
    {
        NSLog(@">> ERROR: Failed allocating a backing-store for the program object: \"%s\"", ba.what());
        
        return false;
    } // catch
    
    GLuint nPID = mpProgram->program();
    
    if(nPID)
    {
        mpProgram->enable();
        {
            m_Graphic[eNBodyLocSampler2D] = glGetUniformLocation(nPID, "splatTexture");
            m_Graphic[eNBodyLocPointSize] = glGetUniformLocation(nPID, "pointSize");
            
            glUniform1i(m_Graphic[eNBodyLocSampler2D], 0);
        }
        mpProgram->disable();
    } // if
    
    return bool(nPID);
} // program

bool Visualizer::acquire(const Properties& rProperties)
{
    bool bSuccess = rProperties.mnBodies > 0;
    
    if(bSuccess)
    {
        bSuccess = buffer(rProperties.mnBodies);
        bSuccess = bSuccess && textures(CFSTR("star"), CFSTR("png"));
        bSuccess = bSuccess && program(CFSTR("nbody"));
    } // if
    
    return bSuccess;
} // acquire

#pragma mark -
#pragma mark Public - Constructor

Visualizer::Visualizer(const Properties& rProperties)
{
    m_Flag[eNBodyIsAcquired] = acquire(rProperties);
    
    if(m_Flag[eNBodyIsAcquired])
    {
        m_Property[eNBodyRotationDelta] = NBody::Defaults::kRotationDelta;
        m_Property[eNBodyViewDistance]  = NBody::Defaults::kViewDistance;
        m_Property[eNBodyViewZoomSpeed] = NBody::Defaults::kScrollZoomSpeed;
        m_Property[eNBodyTimeScale]     = NBody::Scale::kTime;
        m_Property[eNBodyStarScale]     = NBody::Star::kScale;
        m_Property[eNBodyStarSize]      = NBody::Star::kSize * m_Property[eNBodyStarScale];
        m_Property[eNBodyRotationSpeed] = 0.0f;
        m_Property[eNBodyViewTime]      = 0.0f;
        m_Property[eNBodyViewZoom]      = 0.0f;
        
        m_Flag[eNBodyIsResetting] = false;
        m_Flag[eNBodyIsRotating]  = false;
        m_Flag[eNBodyIsEarthView] = false;
        
        m_Frame.width    = NBody::Window::kWidth;
        m_Frame.height   = NBody::Window::kHeight;
        m_Bounds[0]      = GLsizei(m_Frame.width + 0.5f);
        m_Bounds[1]      = GLsizei(m_Frame.height + 0.5f);
        mnCount          = rProperties.mnDemos;
        mpProperties     = Properties::create();
        mnActiveDemo     = 0;
        m_Rotation.x     = 0.0f;
        m_Rotation.y     = 0.0f;
        m_ViewRotation.x = 0.0f;
        m_ViewRotation.y = 0.0f;
    } // if
} // Visualizer

#pragma mark -
#pragma mark Public - Destructor

Visualizer::~Visualizer()
{
    if(m_Graphic[eNBodyBufferID])
    {
        glDeleteBuffers(1, &m_Graphic[eNBodyBufferID]);
        
        m_Graphic[eNBodyBufferID] = 0;
    } // if
    
    if(mpTexture != nullptr)
    {
        delete mpTexture;
        
        mpTexture = nullptr;
    } // if
    
    if(mpGausssian != nullptr)
    {
        delete mpGausssian;
        
        mpGausssian = nullptr;
    } // if
    
    if(mpProgram != nullptr)
    {
        delete mpProgram;
        
        mpProgram = nullptr;
    } // if
    
    if(mpProperties != nullptr)
    {
        delete [] mpProperties;
        
        mpProperties = nullptr;
    } // if
} // Destructor

#pragma mark -
#pragma mark Public - Utilities

void Visualizer::reset(const GLuint& nDemo)
{
    if((nDemo < mnCount) && (mpProperties != nullptr))
    {
        mnActiveDemo = nDemo;
        
        m_Property[eNBodyViewDistance]= mpProperties[nDemo].mnViewDistance;
        
        m_Rotation.x = mpProperties[nDemo].mnRotateX;
        m_Rotation.y = mpProperties[nDemo].mnRotateY;
    } // if
} // reset

void Visualizer::draw(const GLfloat *pPosition)
{
    if(pPosition != nullptr)
    {
        update();
        
        projection();
        lookAt(pPosition);
        
        render(pPosition);
    } // if
} // draw

void Visualizer::stopRotation()
{
    m_Flag[eNBodyIsRotating] = false;
} // stopRotation

void Visualizer::toggleRotation()
{
    m_Flag[eNBodyIsRotating] = !m_Flag[eNBodyIsRotating];
} // toggleRotation

void Visualizer::toggleEarthView()
{
    m_Flag[eNBodyIsEarthView] = !m_Flag[eNBodyIsEarthView];
} // toggleEarthView

#pragma mark -
#pragma mark Public - Query

const bool Visualizer::isValid() const
{
    return m_Flag[eNBodyIsAcquired];
} // isValid

#pragma mark -
#pragma mark Public - Accessors

void Visualizer::setIsResetting(const bool& bReset)
{
    m_Flag[eNBodyIsResetting] = bReset;
} // setIsResetting

void Visualizer::setShowEarthView(const bool& bShowView)
{
    m_Flag[eNBodyIsEarthView] = bShowView;
} // setShowEarthView

void Visualizer::setFrame(const CGSize& rFrame)
{
    if((rFrame.width >= NBody::Window::kWidth) && (rFrame.height >= NBody::Window::kHeight))
    {
        m_Frame.width  = rFrame.width;
        m_Frame.height = rFrame.height;
        m_Bounds[0]    = GLsizei(m_Frame.width + 0.5f);
        m_Bounds[1]    = GLsizei(m_Frame.height + 0.5f);
    } // if
} // setFrame

bool Visualizer::setProperties(const GLuint& nPropertiesCount,
                               const Properties * const pPropertiesrc)
{
    bool bSuccess = m_Flag[eNBodyIsAcquired];
    
    if(bSuccess)
    {
        Properties* pDecriptorDst = Properties::create(nPropertiesCount);
        
        bSuccess = pDecriptorDst != nullptr;
        
        if(bSuccess)
        {
            if(mpProperties != nullptr)
            {
                delete [] mpProperties;
                
                mpProperties = nullptr;
            } // if
            
            mpProperties = pDecriptorDst;
            mnCount      = nPropertiesCount;
        }// if
    } // if
    
    return bSuccess;
} // setProperties

void Visualizer::setRotation(const CGPoint& rRotation)
{
    m_Rotation = rRotation;
} // setRotation

void Visualizer::setRotationChange(const GLfloat& nDelta)
{
    m_Property[eNBodyRotationDelta] = nDelta;
} // setRotationChange

void Visualizer::setRotationSpeed(const GLfloat& nSpeed)
{
    m_Property[eNBodyRotationSpeed] = nSpeed;
} // setRotationSpeed

void Visualizer::setStarScale(const GLfloat& nScale)
{
    if(nScale > 0.0f)
    {
        m_Property[eNBodyStarScale] = nScale;
    } // if
} // setStarScale

void Visualizer::setStarSize(const GLfloat& nSize)
{
    if(nSize > 0.0f)
    {
        m_Property[eNBodyStarSize]  = m_Property[eNBodyStarScale] * nSize;
    } // if
} // setStarSize

void Visualizer::setTimeScale(const GLfloat& nScale)
{
    m_Property[eNBodyTimeScale] = nScale;
} // setTimeScale

void Visualizer::setViewDistance(const GLfloat& nDelta)
{
    m_Property[eNBodyViewDistance] = m_Property[eNBodyViewDistance] + nDelta * m_Property[eNBodyViewZoomSpeed];
    
    if(m_Property[eNBodyViewDistance] < 1.0)
    {
        m_Property[eNBodyViewDistance] = 1.0;
    } // if
} // setViewDistance

void Visualizer::setViewTime(const GLfloat& nResetTime)
{
    m_Property[eNBodyViewTime] = nResetTime;
} // setViewTime

void Visualizer::setViewRotation(const CGPoint& rRotation)
{
    m_ViewRotation = rRotation;
} // setViewRotation

void Visualizer::setViewZoom(const GLfloat& nZoom)
{
    m_Property[eNBodyViewZoom] = nZoom;
} // setViewZoom

void Visualizer::setViewZoomSpeed(const GLfloat& nSpeed)
{
    m_Property[eNBodyViewZoomSpeed] = nSpeed;
} // setViewZoomSpeed
