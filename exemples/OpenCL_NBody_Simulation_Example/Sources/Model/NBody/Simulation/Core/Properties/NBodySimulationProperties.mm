/*
     File: NBodySimulationProperties.mm
 Abstract: 
 N-Body simulation Properties.
 
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
#pragma mark Headers

#import <memory>

#import "CFFile.h"

#import "NBodyConstants.h"
#import "NBodyPreferences.h"
#import "NBodySimulationProperties.h"

#pragma mark -
#pragma mark Private - Namespace

using namespace NBody::Simulation;

#pragma mark -
#pragma mark Private - Type Definitions

typedef NSArray* NSArrayRef;

#pragma mark -
#pragma mark Private - Type Definitions

static const uint32_t kNBodySimulationPropertiesDefaultDemoType = 1;

#pragma mark -
#pragma mark Private - Utilities

static void NBodySimulationPropertiesSetValue(NSNumber* pNumber,
                                              int64_t& value)
{
    if(pNumber)
    {
        value = pNumber.longLongValue;
    } // if
} // NBodySimulationPropertiesSetValue

static void NBodySimulationPropertiesSetValue(NSNumber* pNumber,
                                              uint32_t& value)
{
    if(pNumber)
    {
        value = pNumber.unsignedIntValue;
    } // if
} // NBodySimulationPropertiesSetValue

static void NBodySimulationPropertiesSetValue(NSNumber* pNumber,
                                              double& value)
{
    if(pNumber)
    {
        value = pNumber.doubleValue;
    } // if
} // NBodySimulationPropertiesSetValue

static void NBodySimulationPropertiesSetValue(NSNumber* pNumber,
                                              float& value)
{
    if(pNumber)
    {
        value = pNumber.floatValue;
    } // if
} // NBodySimulationPropertiesSetValue

static void NBodySimulationPropertiesSetValue(NSNumber* pNumber,
                                              bool& value)
{
    if(pNumber)
    {
        value = pNumber.floatValue;
    } // if
} // NBodySimulationPropertiesSetValue

// Note: We're using NSNumber here as the equivalent CFNumberRef does not
//       have representations of unsigned numbers.
static void NBodySimulationPropertiesSetData(NSDictionary* pDictionary,
                                             Properties& properties)
{
    if(pDictionary)
    {
        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefIsGPUOnly],     properties.mbIsGPUOnly);
        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefDemos],         properties.mnDemos);
        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefDemoType],      properties.mnDemoType);
        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefBodies],        properties.mnBodies);
        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefConfig],        properties.mnConfig);
        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefTimeStep],      properties.mnTimeStep);
        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefClusterScale],  properties.mnClusterScale);
        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefVelocityScale], properties.mnVelocityScale);
        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefSoftening],     properties.mnSoftening);
        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefDamping],       properties.mnDamping);
        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefPointSize],     properties.mnPointSize);
        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefViewDistance],  properties.mnViewDistance);
        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefRotateX],       properties.mnRotateX);
        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefRotateY],       properties.mnRotateY);
    } // if
} // NBodySimulationPropertiesSetData

static void NBodySimulationPropertiesSetDefaults(const uint32_t& nDemoType,
                                                 Properties& properties)
{
    properties.mbIsGPUOnly     = NO;
    properties.mnDemos         = 7;
    properties.mnDemoType      = nDemoType;
    properties.mnBodies        = NBody::Bodies::kCount;
    properties.mnConfig        = NBody::Config::eConfigShell;
    properties.mnTimeStep      = NBody::Scale::kTime * 0.016f;
    properties.mnClusterScale  = 1.54f;
    properties.mnVelocityScale = 8.0f;
    properties.mnSoftening     = NBody::Scale::kSoftening * 0.1f;
    properties.mnDamping       = 1.0f;
    properties.mnPointSize     = 1.0f;
    properties.mnViewDistance  = 30.0f;
    properties.mnRotateX       = 0.0f;
    properties.mnRotateY       = 0.0f;
} // NBodySimulationPropertiesSetData

static void NBodySimulationPropertiesSetDefaults(Properties& properties)
{
    NBodySimulationPropertiesSetDefaults(kNBodySimulationPropertiesDefaultDemoType, properties);
} // NBodySimulationPropertiesSetDefaults

static void NBodySimulationPropertiesCopyData(const Properties& propertiesSrc,
                                              Properties& propertiesDst)
{
    propertiesDst.mbIsGPUOnly     = propertiesSrc.mbIsGPUOnly;
    propertiesDst.mnDemos         = propertiesSrc.mnDemos;
    propertiesDst.mnBodies        = propertiesSrc.mnBodies;
    propertiesDst.mnConfig        = propertiesSrc.mnConfig;
    propertiesDst.mnTimeStep      = propertiesSrc.mnTimeStep;
    propertiesDst.mnClusterScale  = propertiesSrc.mnClusterScale;
    propertiesDst.mnVelocityScale = propertiesSrc.mnVelocityScale;
    propertiesDst.mnSoftening     = propertiesSrc.mnSoftening;
    propertiesDst.mnDamping       = propertiesSrc.mnDamping;
    propertiesDst.mnPointSize     = propertiesSrc.mnPointSize;
    propertiesDst.mnViewDistance  = propertiesSrc.mnViewDistance;
    propertiesDst.mnRotateX       = propertiesSrc.mnRotateX;
    propertiesDst.mnRotateY       = propertiesSrc.mnRotateY;
} // NBodySimulationPropertiesCopyData

static int64_t NBodySimulationPropertiesSetData(const uint32_t& demoType,
                                                Properties& properties)
{
    int64_t  nDemos = 0;
    
    CF::File file(CFSTR("NBodySimulationProperties"), CFSTR("plist"));
    
    NSArray* pArray = NSArrayRef(file.plist());
    
    if(pArray)
    {
        nDemos = [pArray count];
        
        bool isValid  = demoType < nDemos;
        
        if(isValid)
        {
            NSDictionary* pDictionary = pArray[demoType];
            
            isValid = pDictionary != nil;
            
            if(isValid)
            {
                NBodySimulationPropertiesSetDefaults(properties);
                NBodySimulationPropertiesSetData(pDictionary, properties);
            } // if
        } // if
        
        if(!isValid)
        {
            nDemos = -1;
        } // if
    } // if
    
    return nDemos;
} // NBodySimulationPropertiesSetData

static Properties* NBodySimulationPropertiesCreate(const size_t& nCount)
{
    Properties* pProperties = nullptr;
    
    CF::File file(CFSTR("NBodySimulationProperties"), CFSTR("plist"));
    
    NSArray* pArray = NSArrayRef(file.plist());
    
    if(pArray)
    {
        size_t nMax = [pArray count];
        size_t iMax = (nCount <= nMax) ? nCount : nMax;
        
        pProperties = new (std::nothrow) Properties[iMax];
        
        if(pProperties != nullptr)
        {
            size_t i = 0;
            
            for(i = 0; i < iMax; ++i)
            {
                NBodySimulationPropertiesSetDefaults(pProperties[i]);
                NBodySimulationPropertiesSetData(pArray[i], pProperties[i]);
            } // for
        } // if
    } // if
    
    return pProperties;
} // NBodySimulationPropertiesCreate

static Properties* NBodySimulationPropertiesCreate(CFStringRef pFilename)
{
    Properties* pProperties = nullptr;
    
    CF::File file(pFilename, CFSTR("plist"));
    
    NSArray* pArray = NSArrayRef(file.plist());
    
    if(pArray)
    {
        size_t iMax = [pArray count];
        
        pProperties = new (std::nothrow) Properties[iMax];
        
        if(pProperties != nullptr)
        {
            size_t i = 0;
            
            NSDictionary* pDictionary = nil;
            
            for(pDictionary in pArray)
            {
                NBodySimulationPropertiesSetDefaults(pProperties[i]);
                NBodySimulationPropertiesSetData(pDictionary, pProperties[i]);
                
                i++;
            } // for
        } // if
    } // if
    
    return pProperties;
} // NBodySimulationPropertiesCreate

static NSDictionary* NBodySimulationPropertiesCreateDictionary(const Properties& properties)
{
    NSArray* pKeys = @[kNBodyPrefIsGPUOnly,
                       kNBodyPrefDemos,
                       kNBodyPrefDemoType,
                       kNBodyPrefBodies,
                       kNBodyPrefConfig,
                       kNBodyPrefTimeStep,
                       kNBodyPrefClusterScale,
                       kNBodyPrefVelocityScale,
                       kNBodyPrefSoftening,
                       kNBodyPrefDamping,
                       kNBodyPrefPointSize,
                       kNBodyPrefViewDistance,
                       kNBodyPrefRotateX,
                       kNBodyPrefRotateY];
    
    NSArray* pObjects = @[@(properties.mbIsGPUOnly),
                          @(properties.mnDemos),
                          @(properties.mnDemoType),
                          @(properties.mnBodies),
                          @(properties.mnConfig),
                          @(properties.mnTimeStep),
                          @(properties.mnClusterScale),
                          @(properties.mnVelocityScale),
                          @(properties.mnSoftening),
                          @(properties.mnDamping),
                          @(properties.mnPointSize),
                          @(properties.mnViewDistance),
                          @(properties.mnRotateX),
                          @(properties.mnRotateY)];
    
    return [NSDictionary dictionaryWithObjects:pObjects
                                       forKeys:pKeys];
} // NBodySimulationPropertiesCreateDictionary

static void NBodySimulationPropertiesUpdatePreferences(const Properties& properties,
                                                       NBodyPreferences* pPreferences)
{
    if(pPreferences)
    {
        pPreferences.isGPUOnly     = properties.mbIsGPUOnly;
        pPreferences.demos         = properties.mnDemos;
        pPreferences.demoType      = properties.mnDemoType;
        pPreferences.bodies        = properties.mnBodies;
        pPreferences.config        = properties.mnConfig;
        pPreferences.timeStep      = properties.mnTimeStep;
        pPreferences.clusterScale  = properties.mnClusterScale;
        pPreferences.velocityScale = properties.mnVelocityScale;
        pPreferences.softening     = properties.mnSoftening;
        pPreferences.damping       = properties.mnDamping;
        pPreferences.pointSize     = properties.mnPointSize;
        pPreferences.viewDistance  = properties.mnViewDistance;
        pPreferences.rotate        = NSMakePoint(properties.mnRotateX, properties.mnRotateY);
    } // if
} // NBodySimulationPropertiesUpdatePreferences

#pragma mark -
#pragma mark Public - Interfaces

Properties::Properties(const uint32_t& type)
{
    NBodySimulationPropertiesSetDefaults(type, *this);

    mnDemos = NBodySimulationPropertiesSetData(mnDemoType, *this);
} // Constructor

Properties::Properties(NSDictionary* pDictionary)
{
    if(pDictionary)
    {
        NBodySimulationPropertiesSetDefaults(*this);
        NBodySimulationPropertiesSetData(pDictionary, *this);
    } // if
} // Constructor

Properties::Properties(NBodyPreferences* pPreferences)
{
    if(pPreferences)
    {
        NBodySimulationPropertiesSetDefaults(*this);
        NBodySimulationPropertiesSetData(pPreferences.preferences, *this);
    } // Constructor
} // Constructor

Properties::~Properties()
{
    mbIsGPUOnly     = NO;
    mnDemos         = 0;
    mnDemoType      = 0;
    mnBodies        = 0;
    mnConfig        = 0;
    mnTimeStep      = 0.0;
    mnClusterScale  = 0.0;
    mnVelocityScale = 0.0;
    mnSoftening     = 0.0;
    mnDamping       = 0.0;
    mnPointSize     = 0.0;
    mnViewDistance  = 0.0;
    mnRotateX       = 0.0;
    mnRotateY       = 0.0;
} // Destructor

Properties::Properties(const Properties& rProperties)
{
    NBodySimulationPropertiesCopyData(rProperties, *this);
} // Copy Constructor

Properties& Properties::operator=(const Properties& rProperties)
{
    if(this != &rProperties)
    {
        NBodySimulationPropertiesCopyData(rProperties, *this);
    } // if
    
    return *this;
} // Operator =

Properties& Properties::operator=(NSDictionary* pDictionary)
{
    NBodySimulationPropertiesSetData(pDictionary, *this);
    
    return *this;
} // Operator =

Properties& Properties::operator=(NBodyPreferences* pPreferences)
{
    if(pPreferences)
    {
        NBodySimulationPropertiesSetData(pPreferences.preferences, *this);
    } // Constructor
    
    return *this;
} // Operator =

NSDictionary* Properties::dictionary()
{
    return NBodySimulationPropertiesCreateDictionary(*this);
} // dictionary

void Properties::update(NBodyPreferences* pPreferences)
{
    NBodySimulationPropertiesUpdatePreferences(*this, pPreferences);
} // update

Properties* Properties::create(const size_t& nCount)
{
    return NBodySimulationPropertiesCreate(nCount);
} // Static constructor

Properties* Properties::create(NSString* pFilename)
{
    return NBodySimulationPropertiesCreate(CFStringRef(pFilename));
} // create

Properties* Properties::create()
{
    return NBodySimulationPropertiesCreate(CFSTR("NBodySimulationProperties"));
} // Static constructor
