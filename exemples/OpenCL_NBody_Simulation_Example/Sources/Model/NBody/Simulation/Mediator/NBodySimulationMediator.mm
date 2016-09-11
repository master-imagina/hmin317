/*
     File: NBodySimulationMediator.mm
 Abstract: 
 A mediator object for managing cpu and gpu bound simulators, along with their labeled-buttons.
 
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

#import <iostream>

#import <OpenCL/OpenCL.h>
#import <OpenGL/gl.h>

#import "GLMSizes.h"

#import "NBodySimulationMediator.h"

using namespace NBody::Simulation;

static const GLuint kNBodyMaxDeviceCount = 128;

// Get the number of coumpute device counts
static GLuint NBodyGetComputeDeviceCount(const GLint& type)
{
    cl_device_id ids[kNBodyMaxDeviceCount] = {0};
    
    GLuint count = -1;
    
    GLint err = clGetDeviceIDs(nullptr, type, kNBodyMaxDeviceCount, ids, &count);
    
    if(err != CL_SUCCESS)
    {
        std::cerr
        << ">> ERROR: NBody Simulation Mediator - Failed acquiring maximum device count!"
        << std::endl;
    } // if
    
    return count;
} // NBodyGetComputeDeviceCount

// Set the defaults for simulator compute
void Mediator::setCompute(const Properties& rProperties)
{
    mnGPUs = NBodyGetComputeDeviceCount(CL_DEVICE_TYPE_GPU);
    
    if(!rProperties.mbIsGPUOnly)
    {
        mbCPUs = NBodyGetComputeDeviceCount(CL_DEVICE_TYPE_CPU) > 0;
    } // if
    
    mnActive = (mbCPUs)
    ? eComputeCPUSingle
    : eComputeGPUPrimary;
} // setCompute

// Initialize all instance variables to their default values
void Mediator::setDefaults(const Properties& rProperties)
{
    
    mnBodies = rProperties.mnBodies;
    mnSize   = 4 * mnBodies * GLM::Size::kFloat;
    
    mnCount    = 0;
    mnGPUs     = 0;
    mbCPUs     = false;
    mpActive   = nullptr;
    mpPosition = nullptr;
    
    mpSimulators[eComputeCPUSingle]    = nullptr;
    mpSimulators[eComputeCPUMulti]     = nullptr;
    mpSimulators[eComputeGPUPrimary]   = nullptr;
    mpSimulators[eComputeGPUSecondary] = nullptr;
} // setDefaults

// Acquire all simulators
void Mediator::acquire(const Properties& rProperties)
{
    m_Properties = rProperties;
    
    if(mnGPUs > 0)
    {
        mpSimulators[eComputeGPUPrimary]
        = new (std::nothrow) Facade(eComputeGPUPrimary, rProperties);
        
        if(mpSimulators[eComputeGPUPrimary] != nullptr)
        {
            mnCount++;
        } // if
    } // if
    
    if(mnGPUs > 1)
    {
        mpSimulators[eComputeGPUSecondary]
        = new (std::nothrow) Facade(eComputeGPUSecondary, rProperties);
        
        if(mpSimulators[eComputeGPUSecondary] != nullptr)
        {
            mnCount++;
        } // if
    } // if
    
    if(mbCPUs)
    {
        mpSimulators[eComputeCPUSingle]
        = new (std::nothrow) Facade(eComputeCPUSingle, rProperties);
        
        if(mpSimulators[eComputeCPUSingle] != nullptr)
        {
            mnCount++;
        } // if
        
        mpSimulators[eComputeCPUMulti]
        = new (std::nothrow) Facade(eComputeCPUMulti, rProperties);
        
        if(mpSimulators[eComputeCPUMulti] != nullptr)
        {
            mnCount++;
        } // if
    } // if
    
    mnActive = (mbCPUs) ? eComputeCPUSingle : eComputeGPUPrimary;
    mpActive = mpSimulators[mnActive];
} // acquire

// Construct a mediator object for GPUs, or CPU and CPUs
Mediator::Mediator(const Properties& rProperties)
{
    setDefaults(rProperties);
    setCompute(rProperties);
    
    acquire(rProperties);
} // Constructor

// Delete alll simulators
Mediator::~Mediator()
{
    GLuint i;
    
    for(i = 0; i < eComputeMax; ++i)
    {
        if(mpSimulators[i] != nullptr)
        {
            delete mpSimulators[i];
            
            mpSimulators[i] = nullptr;
        } // if
    } // for
    
    mnCount = 0;
    mnGPUs  = 0;
    mbCPUs  = false;
} // Destructor

// Is single core cpu simulator active?
const bool Mediator::isCPUSingleCore() const
{
    return mpActive->isCPUSingleCore();
} // isCPUSingleCore

// Is multi-core cpu simulator active?
const bool Mediator::isCPUMultiCore() const
{
    return mpActive->isCPUMultiCore();
} // isCPUMultiCore

// Is primary gpu simulator active?
const bool Mediator::isGPUPrimary() const
{
    return mpActive->isGPUPrimary();
} // isGPUPrimary

// Is secondary (or offline) gpu simulator active?
const bool Mediator::isGPUSecondary() const
{
    return mpActive->isGPUSecondary();
} // isGPUSecondary

// Label for a type of simulator
const std::string& Mediator::label(const Types& nType) const
{
    return mpSimulators[nType]->label();
} // label

// Active simulator type
const Types& Mediator::type() const
{
    return mpActive->type();
} // type

// Check to see if position was acquired
const bool Mediator::hasPosition() const
{
    return mpPosition != nullptr;
} // hasPosition

// Get the total number of simulators
const GLuint Mediator::count() const
{
    return mnCount;
} // count

// Get the relative performance number
const GLdouble Mediator::performance() const
{
    return (mpActive != nullptr) ? mpActive->performance() : 0.0f;
} // performance

// Get the updates performance number
const GLdouble Mediator::updates() const
{
    return (mpActive != nullptr) ? mpActive->updates() : 0.0f;
} // updates

// Pause the current active simulator
void Mediator::pause()
{
    if(mpActive != nullptr)
    {
        mpActive->pause();
    } // if
} // pause

// unpause the current active simulator
void Mediator::unpause()
{
    if(mpActive != nullptr)
    {
        mpActive->unpause();
    } // if
} // unpause

// Select the current simulator to use
void Mediator::select(const Types& type)
{
    if(mpSimulators[type] != nullptr)
    {
        mnActive = type;
        mpActive = mpSimulators[mnActive];
        
        std::cout
        << ">> N-body Simulation: Using \""
        << mpActive->label()
        << "\" simulator with ["
        << mnBodies
        << "] bodies."
        << std::endl;
    } // if
    else
    {
        std::cout
        << ">> ERROR: N-body Simulation: Requested simulator is nullptr!"
        << std::endl;
    } // else
} // select

// Select the current simulator to use
void Mediator::select(const GLuint& index)
{
    Types type = eComputeMax;
    
    if(mbCPUs)
    {
        switch(index)
        {
            case 0:
                type = eComputeCPUSingle;
                break;
                
            case 1:
                type = eComputeCPUMulti;
                break;
                
            case 3:
                type = eComputeGPUSecondary;
                break;
                
            case 2:
            default:
                type = eComputeGPUPrimary;
                break;
        } // switch
    } // if
    else
    {
        switch(index)
        {
            case 1:
                type = eComputeGPUSecondary;
                break;
                
            case 0:
                type = eComputeGPUPrimary;
                break;
        } // switch
    } // else
    
    select(type);
} // select

// Get position data
const GLfloat* Mediator::position() const
{
    return mpPosition;
} // position

// Get the current simulator
Facade* Mediator::simulator()
{
    return mpActive;
} // simulator

// void update position data
void Mediator::update()
{
    GLfloat *pPosition = mpActive->data();
    
    if(pPosition != nullptr)
    {
        if(mpPosition != nullptr)
        {
            std::free(mpPosition);
        } // if
        
        mpPosition = pPosition;
    } // if
} // update

// Reset all the gpu bound simulators
void Mediator::reset()
{
    if(mpActive != nullptr)
    {
        if(mpPosition != nullptr)
        {
            std::free(mpPosition);
            
            mpPosition = nullptr;
            
            std::free(mpActive->data());
        } // if
        
        mpActive->resetProperties(m_Properties);
        
        if(    (mnActive == eComputeGPUPrimary)
           &&  (mpSimulators[eComputeGPUSecondary] != nullptr))
        {
            mpSimulators[eComputeGPUPrimary]->invalidate(true);
            mpSimulators[eComputeGPUSecondary]->invalidate(false);
        } // if
        else if(    (mnActive == eComputeGPUSecondary)
                &&  (mpSimulators[eComputeGPUPrimary] != nullptr))
        {
            mpSimulators[eComputeGPUPrimary]->invalidate(false);
            mpSimulators[eComputeGPUSecondary]->invalidate(true);
        } // else if
        else if (mnActive == eComputeGPUPrimary)
        {
            mpSimulators[eComputeGPUPrimary]->invalidate(true);
        } // else if
        
        mpActive->unpause();
    } // if
} // NBodyResetSimulators
