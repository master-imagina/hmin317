/*
     File: NBodySimulationDataSplit.mm
 Abstract: 
 Utility class for managing cpu bound device and host split position and velocity data.
 
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

#import <iostream>

#import "NBodySimulationDataSplit.h"

#pragma mark -
#pragma mark Private - Namespace

using namespace NBody::Simulation::Data;

#pragma mark -
#pragma mark Private - Constants

static const cl_int kNBodySimDevMemPosErr = -200;
static const cl_int kNBodySimDevMemVelErr = -201;

static const size_t kNBodySimSplitDataMemSize = sizeof(cl_mem);

#pragma mark -
#pragma mark Private - Data Structures

struct NBodySimulationSplitData
{
    GLfloat* mpHost;
    cl_mem   mpDevice;
};

struct NBody::Simulation::Data::Split3D
{
    NBodySimulationSplitData m_Mass;
    NBodySimulationSplitData m_Position[3];
    NBodySimulationSplitData m_Velocity[3];
};

#pragma mark -
#pragma mark Private - Utilities - Constructors

Split3DRef Split::create(const size_t& nCount,
                         const size_t& nSamples)
{
    Split3DRef pSplit = Split3DRef(std::calloc(1, sizeof(Split3D)));
    
    if(pSplit != nullptr)
    {
        pSplit->m_Mass.mpHost = (GLfloat *)std::calloc(nCount, nSamples);
        
        pSplit->m_Position[eAxisX].mpHost = (GLfloat *)std::calloc(nCount, nSamples);
        pSplit->m_Position[eAxisY].mpHost = (GLfloat *)std::calloc(nCount, nSamples);
        pSplit->m_Position[eAxisZ].mpHost = (GLfloat *)std::calloc(nCount, nSamples);
        
        pSplit->m_Velocity[eAxisX].mpHost = (GLfloat *)std::calloc(nCount, nSamples);
        pSplit->m_Velocity[eAxisY].mpHost = (GLfloat *)std::calloc(nCount, nSamples);
        pSplit->m_Velocity[eAxisZ].mpHost = (GLfloat *)std::calloc(nCount, nSamples);
    } // if
    
    return pSplit;
} // create

GLint Split::acquire(const GLuint& nIndex,
                     cl_context pContext)
{
    GLint err = CL_INVALID_CONTEXT;
    
    if(pContext != nullptr)
    {
        mpSplit->m_Position[nIndex].mpDevice = clCreateBuffer(pContext,
                                                              mnFlags,
                                                              mnSize,
                                                              mpSplit->m_Position[nIndex].mpHost,
                                                              &err);
        
        if(err != CL_SUCCESS)
        {
            return kNBodySimDevMemPosErr;
        } // if
        
        mpSplit->m_Velocity[nIndex].mpDevice = clCreateBuffer(pContext,
                                                              mnFlags,
                                                              mnSize,
                                                              mpSplit->m_Velocity[nIndex].mpHost,
                                                              &err);
        
        if(err != CL_SUCCESS)
        {
            return kNBodySimDevMemVelErr;
        } // if
    } // if
    
    return err;
} // acquire

#pragma mark -
#pragma mark Public - Constructor

Split::Split(const Properties& rProperties)
{
    mnBodies  = rProperties.mnBodies;
    mnSamples = sizeof(GLfloat);
    mnSize    = mnSamples * mnBodies;
    mnFlags   = cl_mem_flags(CL_MEM_READ_WRITE | CL_MEM_USE_HOST_PTR);
    mpSplit   = create(mnBodies, mnSamples);
} // Constructor

#pragma mark -
#pragma mark Public - Destructor

Split::~Split()
{
    if(mpSplit != nullptr)
    {
        GLuint i;
        
        for(i = 0; i < 3; ++i)
        {
            // Host Position
            if(mpSplit->m_Position[i].mpHost != nullptr)
            {
                std::free(mpSplit->m_Position[i].mpHost);
                
                mpSplit->m_Position[i].mpHost = nullptr;
            } // if
            
            // Host Velocity
            if(mpSplit->m_Velocity[i].mpHost != nullptr)
            {
                std::free(mpSplit->m_Velocity[i].mpHost);
                
                mpSplit->m_Velocity[i].mpHost = nullptr;
            } // if
            
            // Device Position
            if(mpSplit->m_Position[i].mpDevice != nullptr)
            {
                clReleaseMemObject(mpSplit->m_Position[i].mpDevice);
                
                mpSplit->m_Position[i].mpDevice = nullptr;
            } // if
            
            // Device Velocity
            if(mpSplit->m_Velocity[i].mpDevice != nullptr)
            {
                clReleaseMemObject(mpSplit->m_Velocity[i].mpDevice);
                
                mpSplit->m_Velocity[i].mpDevice = nullptr;
            } // if
        } // for
        
        if(mpSplit->m_Mass.mpHost != nullptr)
        {
            std::free(mpSplit->m_Mass.mpHost);
            
            mpSplit->m_Mass.mpHost = nullptr;
        } // if
        
        if(mpSplit->m_Mass.mpDevice != nullptr)
        {
            clReleaseMemObject(mpSplit->m_Mass.mpDevice);
            
            mpSplit->m_Mass.mpDevice = nullptr;
        } // if
        
        std::free(mpSplit);
        
        mpSplit = nullptr;
    } // if
} // Destructor

#pragma mark -
#pragma mark Public - Accessors

const GLfloat* Split::mass() const
{
    return mpSplit->m_Mass.mpHost;
} // mass

const GLfloat* Split::position(const Axis& nCoord) const
{
    return mpSplit->m_Position[nCoord].mpHost;
} // position

const GLfloat* Split::velocity(const Axis& nCoord) const
{
    return mpSplit->m_Velocity[nCoord].mpHost;
} // velocity

#pragma mark -
#pragma mark Public - Utilities

GLfloat* Split::mass()
{
    return mpSplit->m_Mass.mpHost;
} // mass

GLfloat* Split::position(const Axis& nCoord)
{
    return mpSplit->m_Position[nCoord].mpHost;
} // position

GLfloat* Split::velocity(const Axis& nCoord)
{
    return mpSplit->m_Velocity[nCoord].mpHost;
} // velocity

GLint Split::acquire(cl_context pContext)
{
    GLint err = CL_INVALID_CONTEXT;
    
    if(pContext != nullptr)
    {
        mpSplit->m_Mass.mpDevice = clCreateBuffer(pContext,
                                                  mnFlags,
                                                  mnSize,
                                                  mpSplit->m_Mass.mpHost,
                                                  &err);
        
        if(err != CL_SUCCESS)
        {
            std::cerr << ">> ERROR: Failed acquring device memory!" << std:: endl;
            
            return kNBodySimDevMemPosErr;
        } // if
        
        GLuint i;
        
        for(i = 0; i < 3; ++i)
        {
            err = acquire(i, pContext);
            
            if(err != CL_SUCCESS)
            {
                std::cerr
                << ">> ERROR: Failed acquring device memory at index ["
                << i
                << "]!"
                << std:: endl;
                
                break;
            } // if
        } // for
    } // if
    
    return err;
} // acquire

GLint Split::bind(const cl_uint& nStartIndex,
                  cl_kernel pKernel)
{
    GLint err = CL_INVALID_KERNEL;
    
    if(pKernel != nullptr)
    {
        size_t  sizes[7];
        void*   pValues[7];
        
        pValues[0]  = &mpSplit->m_Position[eAxisX].mpDevice;
        pValues[1]  = &mpSplit->m_Position[eAxisY].mpDevice;
        pValues[2]  = &mpSplit->m_Position[eAxisZ].mpDevice;
        pValues[3]  = &mpSplit->m_Velocity[eAxisX].mpDevice;
        pValues[4]  = &mpSplit->m_Velocity[eAxisY].mpDevice;
        pValues[5]  = &mpSplit->m_Velocity[eAxisZ].mpDevice;
        pValues[6]  = &mpSplit->m_Mass.mpDevice;
        
        sizes[0]  = kNBodySimSplitDataMemSize;
        sizes[1]  = kNBodySimSplitDataMemSize;
        sizes[2]  = kNBodySimSplitDataMemSize;
        sizes[3]  = kNBodySimSplitDataMemSize;
        sizes[4]  = kNBodySimSplitDataMemSize;
        sizes[5]  = kNBodySimSplitDataMemSize;
        sizes[6]  = kNBodySimSplitDataMemSize;
        
        cl_uint i;
        
        for(i = 0; i < 7; ++i)
        {
            err = clSetKernelArg(pKernel,
                                 nStartIndex + i,
                                 sizes[i],
                                 pValues[i]);
            
            if(err != CL_SUCCESS)
            {
                return err;
            } // if
        } // for
    } // if
    
    return err;
} // bind
