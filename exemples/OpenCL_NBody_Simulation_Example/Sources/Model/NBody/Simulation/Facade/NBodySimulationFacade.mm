/*
     File: NBodySimulationFacade.mm
 Abstract: 
 A facade for managing cpu or gpu bound simulators, along with their labeled-button.
 
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

#import <cstdio>

#import <sys/types.h>
#import <sys/sysctl.h>

#import "CFQueryHardware.h"

#import "NBodySimulationCPU.h"
#import "NBodySimulationGPU.h"
#import "NBodySimulationFacade.h"

#pragma mark -
#pragma mark Private - Namespace

using namespace NBody::Simulation;

#pragma mark -
#pragma mark Private - Accessors

// Acquire a label for the gpu bound simulator
void Facade::setLabel(const GLint& nDevIndex,
                      const GLuint& nDevices,
                      const std::string& rDevice)
{
    CF::Query::Hardware hw;
    
    std::string model = hw.model();
    std::size_t found = model.find("MacPro");
    std::string label = nDevIndex ? "Secondary" : "Primary";
    
    bool isMacPro  = found != std::string::npos;
    bool isDualGPU = nDevices == 2;
    
    if(isMacPro && isDualGPU && nDevIndex)
    {
        label = "Primary + " + label;
    } // if
    
    m_Label = "SIM: " + label + " " + rDevice;
} // setLabel

#pragma mark -
#pragma mark Private - Constructors

Base *Facade::create(const GLint& nDevIndex,
                     const Properties& rProperties)
{
    Base *pSimulator = new (std::nothrow) GPU(rProperties, nDevIndex);
    
    if(pSimulator != nullptr)
    {
        size_t spin = 0;
        
        pSimulator->start();
        
        while(!pSimulator->isAcquired())
        {
            spin++;
        } // while
        
        mbIsGPU = true;
        
        setLabel(nDevIndex,
                 pSimulator->devices(),
                 pSimulator->name());
    } // if
    
    return pSimulator;
} // create

Base *Facade::create(const bool& bIsThreaded,
                     const std::string& rLabel,
                     const Properties& rProperties)
{
    Base *pSimulator = new (std::nothrow) CPU(rProperties, true, bIsThreaded);
    
    if(pSimulator != nullptr)
    {
        pSimulator->start();
        
        mbIsGPU = false;
        m_Label = "SIM: " + rLabel;
    } // if
    
    return pSimulator;
} // create

#pragma mark -
#pragma mark Public - Constructor

Facade::Facade(const Types& nType,
               const Properties& rProperties)
{
    mnType   = nType;
    m_Label  = "";
    
    switch(mnType)
    {
        case eComputeCPUSingle:
            mpSimulator = create(false, "Vector Single Core CPU", rProperties);
            break;
            
        case eComputeCPUMulti:
            mpSimulator = create(true, "Vector Multi Core CPU", rProperties);
            break;
            
        case eComputeGPUSecondary:
            mpSimulator = create(1, rProperties);
            break;
            
        case eComputeGPUPrimary:
        default:
            mpSimulator = create(0, rProperties);
            break;
    } // switch
} // Constructor

#pragma mark -
#pragma mark Public - Destructor

Facade::~Facade()
{
    if(mpSimulator != nullptr)
    {
        mpSimulator->exit();
        
        delete mpSimulator;
        
        mpSimulator = nullptr;
    } // if
    
    m_Label.clear();
} // Destructor

#pragma mark -
#pragma mark Public - Utilities - Simulator

void Facade::pause()
{
    mpSimulator->pause();
} // pause

void Facade::unpause()
{
    mpSimulator->unpause();
} // unpause

void Facade::resetProperties(const Properties& rProperties)
{
    mpSimulator->resetProperties(rProperties);
} // resetProperties

void Facade::invalidate(const bool& doInvalidate)
{
    mpSimulator->invalidate(doInvalidate);
} // invalidate

GLfloat *Facade::data()
{
    return mpSimulator->data();
} // data

Base* Facade::simulator()
{
    return mpSimulator;
} // simulator

#pragma mark -
#pragma mark Public - Accessors - Quaries

const bool Facade::isActive() const
{
    return mpSimulator != nullptr;
} // isActive

const bool Facade::isAcquired() const
{
    return mpSimulator->isAcquired();
} // isAcquired

const bool Facade::isPaused() const
{
    return mpSimulator->isPaused();
} // isPaused

const bool Facade::isStopped() const
{
    return mpSimulator->isStopped();
} // isStopped

// Is single core cpu simulator active?
const bool Facade::isCPUSingleCore() const
{
    return mnType == eComputeCPUSingle;
} // isCPUSingleCore

// Is multi-core cpu simulator active?
const bool Facade::isCPUMultiCore() const
{
    return mnType == eComputeCPUMulti;
} // isCPUMultiCore

// Is primary gpu simulator active?
const bool Facade::isGPUPrimary() const
{
    return mnType == eComputeGPUPrimary;
} // isGPUPrimary

// Is secondary (or offline) gpu simulator active?
const bool Facade::isGPUSecondary() const
{
    return mnType == eComputeGPUSecondary;
} // isGPUSecondary

#pragma mark -
#pragma mark Public - Accessors - Getters

void Facade::positionInRange(GLfloat *pDst)
{
    mpSimulator->positionInRange(pDst);
} // positionInRange

void Facade::position(GLfloat *pDst)
{
    mpSimulator->position(pDst);
} // position

void Facade::velocity(GLfloat *pDst)
{
    mpSimulator->velocity(pDst);
} // velocity

const GLdouble Facade::performance() const
{
    return mpSimulator->performance();
} // performance

const GLdouble Facade::updates() const
{
    return mpSimulator->updates();
} // updates

const GLdouble Facade::year() const
{
    return mpSimulator->year();
} // year

const size_t Facade::size() const
{
    return mpSimulator->size();
} // size

const std::string& Facade::label() const
{
    return m_Label;
} // label

const Types& Facade::type() const
{
    return mnType;
} // type

#pragma mark -
#pragma mark Public - Accessors - Setters

void Facade::setRange(const GLint& min,
                      const GLint& max)
{
    mpSimulator->setRange(min, max);
} // setRange

void Facade::setProperties(const Properties& rProperties)
{
    mpSimulator->setProperties(rProperties);
} // setProperties

void Facade::setData(const GLfloat * const pData)
{
    mpSimulator->setData(pData);
} // setData

void Facade::setPosition(const GLfloat * const pSrc)
{
    mpSimulator->setPosition(pSrc);
} // setPosition

void Facade::setVelocity(const GLfloat * const pSrc)
{
    mpSimulator->setVelocity(pSrc);
} // setVelocity
