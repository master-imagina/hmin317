/*
     File: NBodySimulationDataURDS.mm
 Abstract: 
 Functor for generating random split-data sets for the cpu or gpu bound simulator using uniform random distribution.
 
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

#import "NBodyConstants.h"
#import "NBodySimulationDataGalaxy.h"
#import "NBodySimulationDataURDS.h"

#pragma mark -
#pragma mark Private - Namespace

using namespace NBody::Simulation::Data;

#pragma mark -
#pragma mark Private - Utilities

void URDS::configRandom()
{
    GLfloat scale  = m_Scale[0] * std::max(1.0f, mnBCScale);
    GLfloat vscale = m_Scale[1] * scale;
    GLfloat lenSqr = 0.0f;
    
    simd::float3 point    = 0.0f;
    simd::float3 velocity = 0.0f;
    
    size_t i = 0;
    
    while(i < mnBodies)
    {
        point  = mpDistribution[eNBodyRandIntervalLenIsTwo]->rand();
        lenSqr = simd::length_squared(point);
        
        if(lenSqr > 1.0f)
        {
            continue;
        } // if
        
        velocity = mpDistribution[eNBodyRandIntervalLenIsTwo]->rand();
        lenSqr   = simd::length_squared(velocity);
        
        if(lenSqr > 1.0f)
        {
            continue;
        } // if
        
        point *= scale;
        
        mpPosition[eAxisX][i] = point.x;
        mpPosition[eAxisY][i] = point.y;
        mpPosition[eAxisZ][i] = point.z;
        
        mpMass[i] = 1.0f; // mass
        
        velocity *= vscale;
        
        mpVelocity[eAxisX][i] = velocity.x;
        mpVelocity[eAxisY][i] = velocity.y;
        mpVelocity[eAxisZ][i] = velocity.z;
        
        i++;
    } // while
} // configRandom

void URDS::configShell()
{
    GLfloat scale  = m_Scale[0];
    GLfloat vscale = scale * m_Scale[1];
    GLfloat inner  = 2.5f * scale;
    GLfloat outer  = 4.0f * scale;
    GLfloat len    = 0.0f;
    GLfloat dot    = 0.0f;
    
    simd::float3 point    = 0.0f;
    simd::float3 position = 0.0f;
    simd::float3 velocity = 0.0f;
    simd::float3 axis     = 0.0f;
    
    size_t i = 0;
    
    while(i < mnBodies)
    {
        point = mpDistribution[eNBodyRandIntervalLenIsTwo]->rand();
        len   = simd::length(point);
        point = simd::normalize(point);
        
        if(len > 1)
        {
            continue;
        } // if
        
        position = mpDistribution[eNBodyRandIntervalLenIsOne]->rand();
        position *= (outer - inner);
        position += inner;
        position *= point;
        
        mpPosition[eAxisX][i] = position.x;
        mpPosition[eAxisY][i] = position.y;
        mpPosition[eAxisZ][i] = position.z;
        
        mpMass[i] = 1.0f;
        
        axis = {0.0f, 0.0f, 1.0f};
        axis = simd::normalize(axis);
        dot  = simd::dot(point, axis);
        
        if((1.0f - dot) < 1.0e-6)
        {
            axis.x = point.y;
            axis.y = point.x;
            
            axis = simd::normalize(axis);
        } // if
        
        velocity = {mpPosition[eAxisX][i], mpPosition[eAxisY][i], mpPosition[eAxisZ][i]};
        velocity = simd::cross(velocity, axis);
        velocity *= vscale;
        
        mpVelocity[eAxisX][i] = velocity.x;
        mpVelocity[eAxisY][i] = velocity.y;
        mpVelocity[eAxisZ][i] = velocity.z;
        
        i++;
    } // while
} // configShell

void URDS::configMWM31()
{
    Data::Galaxy galaxy(mnBodies);
    
    if(galaxy.rows())
    {
        // The Milky-Way (MW) seems to be on a collision course with our
        // neighbour spiral galaxy Andromeda (M31)
        
        GLfloat scale  = m_Scale[0];
        GLfloat vscale = scale * m_Scale[1];
        GLfloat mscale = scale * scale * scale;
        
        GLint numPoints = 0;
        
        simd::float3 position = 0.0f;
        simd::float3 velocity = 0.0f;
        
        GLfloat bMass = 0.0f;
        
        size_t i = 0;
        
        while(!galaxy.eof())
        {
            numPoints++;
            
            std::vector<float> vec = galaxy.floats();
            
            bMass = vec[0];
            
            position = {vec[1], vec[2], vec[3]};
            velocity = {vec[4], vec[5], vec[6]};
            
            bMass *= mscale;
            
            position *= scale;
            
            mpPosition[eAxisX][i] = position.x;
            mpPosition[eAxisY][i] = position.y;
            mpPosition[eAxisZ][i] = position.z;
            
            mpMass[i] = bMass;
            
            velocity *= vscale;
            
            mpVelocity[eAxisX][i] = velocity.x;
            mpVelocity[eAxisY][i] = velocity.y;
            mpVelocity[eAxisZ][i] = velocity.z;
            
            i++;
        } // while
    } // if
} // configMWM31

void URDS::configExpand()
{
    GLfloat scale  = m_Scale[0] * std::max(1.0f, mnBCScale);
    GLfloat vscale = scale * m_Scale[1];
    GLfloat lenSqr = 0.0f;
    
    simd::float3 point    = 0.0f;
    simd::float3 velocity = 0.0f;
    
    size_t i = 0;
    
    while(i < mnBodies)
    {
        point  = mpDistribution[eNBodyRandIntervalLenIsTwo]->rand();
        lenSqr = simd::length_squared(point);
        
        if(lenSqr > 1.0f)
        {
            continue;
        } // if
        
        point *= scale;
        
        mpPosition[eAxisX][i] = point.x;
        mpPosition[eAxisY][i] = point.y;
        mpPosition[eAxisZ][i] = point.z;
        
        mpMass[i] = 1.0f; // mpMass
        
        velocity *= vscale;
        
        mpVelocity[eAxisX][i] = velocity.x;
        mpVelocity[eAxisY][i] = velocity.y;
        mpVelocity[eAxisZ][i] = velocity.z;
        
        i++;
    } // for
} // configExpand

#pragma mark -
#pragma mark Public - Interfaces

URDS::URDS(const Properties& rProperties)
: URDB::URDB(rProperties)
{
    mnCount   = GLfloat(mnBodies);
    mnBCScale = mnCount / 1024.0f;
} // Constructor

URDS::~URDS()
{
    mnCount   = 0.0f;
    mnBCScale = 0.0f;
    mpMass    = nullptr;
    
    mpPosition[eAxisX] = nullptr;
    mpPosition[eAxisY] = nullptr;
    mpPosition[eAxisZ] = nullptr;
    
    mpVelocity[eAxisX] = nullptr;
    mpVelocity[eAxisY] = nullptr;
    mpVelocity[eAxisZ] = nullptr;
} // Destructor

bool URDS::operator()(Split* pSplit)
{
    bool bSuccess = pSplit != nullptr;
    
    if(bSuccess)
    {
        mpMass = pSplit->mass();
        
        mpPosition[eAxisX] = pSplit->position(eAxisX);
        mpPosition[eAxisY] = pSplit->position(eAxisY);
        mpPosition[eAxisZ] = pSplit->position(eAxisZ);
        
        mpVelocity[eAxisX] = pSplit->velocity(eAxisX);
        mpVelocity[eAxisY] = pSplit->velocity(eAxisY);
        mpVelocity[eAxisZ] = pSplit->velocity(eAxisZ);
        
        switch(mnConfig)
        {
            case NBody::eConfigShell:
                configShell();
                break;
                
            case NBody::eConfigMWM31:
                configMWM31();
                break;
                
            case NBody::eConfigExpand:
                configExpand();
                break;
                
            case NBody::eConfigRandom:
            default:
                configRandom();
                break;
        } // switch
    } // if
    
    return bSuccess;
} // operator()
