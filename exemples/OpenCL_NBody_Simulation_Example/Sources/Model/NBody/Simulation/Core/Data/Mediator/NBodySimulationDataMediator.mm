/*
     File: NBodySimulationDataMediator.mm
 Abstract: 
 Utility class for managing cpu bound device and host memories.
 
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

#import "GLMSizes.h"

#import "NBodySimulationDataCopier.h"
#import "NBodySimulationDataURDS.h"
#import "NBodySimulationDataMediator.h"

#pragma mark -
#pragma mark Private - Namespace

using namespace NBody::Simulation::Data;

#pragma mark -
#pragma mark Public - Constructor

Mediator::Mediator(const Properties& rProperties)
{
    mnBodies     = rProperties.mnBodies;
    mnReadIndex  = 0;
    mnWriteIndex = 1;
    mpPacked     = new (std::nothrow) Packed(rProperties);
    mpSplit[0]   = new (std::nothrow) Split(rProperties);
    mpSplit[1]   = new (std::nothrow) Split(rProperties);
    m_Queue      = dispatch_queue_create("com.apple.nbody.simulation.data.mediator.main", 0);
} // Constructor

#pragma mark -
#pragma mark Public - Destructor

Mediator::~Mediator()
{
    if(mpPacked != nullptr)
    {
        delete mpPacked;
        
        mpPacked = nullptr;
    } // if
    
    if(mpSplit[0] != nullptr)
    {
        delete mpSplit[0];
        
        mpSplit[0] = nullptr;
    } // if
    
    if(mpSplit[1] != nullptr)
    {
        delete mpSplit[1];
        
        mpSplit[1] = nullptr;
    } // if
    
    dispatch_release(m_Queue);
} // Destructor

#pragma mark -
#pragma mark Public - Utilities

void Mediator::swap()
{
    std::swap(mnReadIndex, mnWriteIndex);
} // step

GLint Mediator::acquire(cl_context pContext)
{
    GLint err = mpSplit[0]->acquire(pContext);
    
    if(err == CL_SUCCESS)
    {
        err = mpSplit[1]->acquire(pContext);
        
        if(err == CL_SUCCESS)
        {
            err = mpPacked->acquire(pContext);
        } // if
    } // if
    
    return err;
} // setup

GLint Mediator::bind(cl_kernel pKernel)
{
    GLint err = mpSplit[mnWriteIndex]->bind(0, pKernel);
    
    if(err == CL_SUCCESS)
    {
        err = mpSplit[mnReadIndex]->bind(6, pKernel);
        
        if(err == CL_SUCCESS)
        {
            err = mpPacked->bind(13, pKernel);
        } // if
    } // if
    
    return err;
} // bind

GLint Mediator::update(cl_kernel pKernel)
{
    GLint err = mpSplit[mnWriteIndex]->bind(0, pKernel);
    
    if(err == CL_SUCCESS)
    {
        err = mpSplit[mnReadIndex]->bind(6, pKernel);
        
        if(err == CL_SUCCESS)
        {
            err = mpPacked->update(13, pKernel);
        } // if
    } // if
    
    return err;
} // bind

void Mediator::reset(const NBody::Simulation::Properties& rProperties)
{
    URDS urds(rProperties);
    
    urds(mpSplit[mnReadIndex]);
    
    Copier copier(mnBodies);
    
    copier(mpSplit[mnReadIndex], mpPacked);
} // reset

#pragma mark -
#pragma mark Public - Accessors

const GLfloat* Mediator::data() const
{
    return mpPacked->data();
} // position

GLint Mediator::positionInRange(const CFRange& range,
                                GLfloat* pDst)
{
    GLint err = CL_INVALID_VALUE;
    
    if(pDst != nullptr)
    {
        size_t nMin = (range.location > 0) ? range.location : 0;
        size_t nMax = (range.length   > 0) ? range.length   : (mnBodies - nMin + 1);
        
        size_t nOffset = nMin * 4;
        
        pDst += nOffset;
        
        const GLfloat * const pData = mpPacked->data();
        
        dispatch_apply(nMax, m_Queue, ^(size_t i) {
            const size_t j = 4 * i + nMin;
            
            pDst[j]   = pData[j];
            pDst[j+1] = pData[j+1];
            pDst[j+2] = pData[j+2];
            pDst[j+3] = pData[j+3];
        });
        
        err = CL_SUCCESS;
    } // if
    
    return err;
} // positionInRange

GLint Mediator::positionInRange(const size_t& nMin,
                                const size_t& nMax,
                                GLfloat* pDst)
{
    const CFIndex nLen  = (nMax) ? (nMax - nMin + 1) : mnBodies;
    const CFRange range = CFRangeMake(nMin, nLen);
    
    return positionInRange(range, pDst);
} // positionInRange

GLint Mediator::position(const size_t& nMax,
                         GLfloat* pDst)
{
    GLint err = CL_INVALID_VALUE;
    
    if(pDst != nullptr)
    {
        const GLfloat * const pData = mpPacked->data();
        
        dispatch_apply(nMax, m_Queue, ^(size_t i) {
            const size_t j = 4 * i;
            
            pDst[j]   = pData[j];
            pDst[j+1] = pData[j+1];
            pDst[j+2] = pData[j+2];
            pDst[j+3] = pData[j+3];
        });
        
        err = CL_SUCCESS;
    } // if
    
    return err;
} // position

GLint Mediator::setPosition(const GLfloat * const pSrc)
{
    GLint err = CL_INVALID_VALUE;
    
    if(pSrc != nullptr)
    {
        GLfloat* pData = mpPacked->data();
        
        GLfloat* pPositionX = mpSplit[mnReadIndex]->position(eAxisX);
        GLfloat* pPositionY = mpSplit[mnReadIndex]->position(eAxisY);
        GLfloat* pPositionZ = mpSplit[mnReadIndex]->position(eAxisZ);
        
        dispatch_apply(mnBodies, m_Queue, ^(size_t i) {
            const size_t j = 4 * i;
            
            pData[j]   = pSrc[j];
            pData[j+1] = pSrc[j+1];
            pData[j+2] = pSrc[j+2];
            
            pPositionX[i] = pData[j];
            pPositionY[i] = pData[j+1];
            pPositionZ[i] = pData[j+2];
        });
        
        err = CL_SUCCESS;
    } // if
    
    return err;
} // setPosition

GLint Mediator::velocity(GLfloat* pDst)
{
    GLint err = CL_INVALID_VALUE;
    
    if(pDst != nullptr)
    {
        const GLfloat * const pVelocityX = mpSplit[mnReadIndex]->velocity(eAxisX);
        const GLfloat * const pVelocityY = mpSplit[mnReadIndex]->velocity(eAxisY);
        const GLfloat * const pVelocityZ = mpSplit[mnReadIndex]->velocity(eAxisZ);
        
        dispatch_apply(mnBodies, m_Queue, ^(size_t i) {
            const size_t j = 4 * i;
            
            pDst[j]   = pVelocityX[i];
            pDst[j+1] = pVelocityY[i];
            pDst[j+2] = pVelocityZ[i];
        });
        
        err = CL_SUCCESS;
    } // if
    
    return err;
} // velocity

GLint Mediator::setVelocity(const GLfloat * const pSrc)
{
    GLint err = CL_INVALID_VALUE;
    
    if(pSrc != nullptr)
    {
        GLfloat* pVelocityX = mpSplit[mnReadIndex]->velocity(eAxisX);
        GLfloat* pVelocityY = mpSplit[mnReadIndex]->velocity(eAxisY);
        GLfloat* pVelocityZ = mpSplit[mnReadIndex]->velocity(eAxisZ);
        
        dispatch_apply(mnBodies, m_Queue, ^(size_t i) {
            const size_t j = 4 * i;
            
            pVelocityX[i] = pSrc[j];
            pVelocityY[i] = pSrc[j+1];
            pVelocityZ[i] = pSrc[j+2];
        });
        
        err = CL_SUCCESS;
    } // if
    
    return err;
} // setVelocity
