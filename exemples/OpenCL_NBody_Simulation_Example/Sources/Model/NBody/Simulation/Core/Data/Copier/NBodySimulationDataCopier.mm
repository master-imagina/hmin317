/*
     File: NBodySimulationDataCopier.mm
 Abstract: 
 Functor for copying split position data to/from packed position data.
 
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

#import "NBodySimulationDataCopier.h"

using namespace NBody::Simulation::Data;

Copier::Copier(const size_t& nCount)
{
    mnCount = nCount;
    m_Queue = dispatch_queue_create("com.apple.nbody.simulation.data.copier.main", 0);
} // Constructor

Copier::~Copier()
{
    dispatch_release(m_Queue);
} // Destructor

bool Copier::operator()(const Split  * const pSplit,
                        Packed* pPacked)
{
    bool bSuccess = (pSplit != nullptr) && (pPacked != nullptr);
    
    if(bSuccess)
    {
        GLfloat* pData = pPacked->data();
        
        const GLfloat * const pMass      = pSplit->mass();
        const GLfloat * const pPositionX = pSplit->position(eAxisX);
        const GLfloat * const pPositionY = pSplit->position(eAxisY);
        const GLfloat * const pPositionZ = pSplit->position(eAxisZ);
        
        dispatch_apply(mnCount, m_Queue, ^(size_t i) {
            const size_t j = 4 * i;
            
            pData[j]   = pPositionX[i];
            pData[j+1] = pPositionY[i];
            pData[j+2] = pPositionZ[i];
            pData[j+3] = pMass[i];
        });
    } // if
    
    return bSuccess;
} // operator()

bool Copier::operator()(const Packed * const pPacked,
                        Split* pSplit)
{
    bool bSuccess = (pSplit != nullptr) && (pPacked != nullptr);
    
    if(bSuccess)
    {
        const GLfloat * const pData = pPacked->data();
        
        GLfloat* pMass      = pSplit->mass();
        GLfloat* pPositionX = pSplit->position(eAxisX);
        GLfloat* pPositionY = pSplit->position(eAxisY);
        GLfloat* pPositionZ = pSplit->position(eAxisZ);
        
        dispatch_apply(mnCount, m_Queue, ^(size_t i) {
            const size_t j = 4 * i;
            
            pPositionX[i] = pData[j];
            pPositionY[i] = pData[j+1];
            pPositionZ[i] = pData[j+2];
            pMass[i]      = pData[j+3];
        });
    } // if
    
    return bSuccess;
} // operator()
