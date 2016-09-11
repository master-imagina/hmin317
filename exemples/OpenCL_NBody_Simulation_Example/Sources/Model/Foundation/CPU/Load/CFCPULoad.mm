/*
     File: CFCPULoad.mm
 Abstract: 
 Utility class for calculating load on CPU cores.
 
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

#import "CFCPUHostInfo.h"
#import "CFCPULoad.h"

using namespace CF::CPU;

Load::Load()
{
    mnTotalTime = 0;
    mnUserTime  = 0;
} // Constructor

Load::Load(const Load& rLoad)
{
    mnTotalTime = rLoad.mnTotalTime;
    mnUserTime  = rLoad.mnUserTime;
} // Copy Constructor

Load::~Load()
{
    mnTotalTime = 0;
    mnUserTime  = 0;
} // Constructor

Load& Load::operator=(const Load& rLoad)
{
    if(this != &rLoad)
    {
        mnTotalTime = rLoad.mnTotalTime;
        mnUserTime  = rLoad.mnUserTime;
    } // if
    
    return *this;
} // Assignment Operator

const size_t Load::total() const
{
    return mnTotalTime;
} // total

const size_t Load::user() const
{
    return mnUserTime;
} // user

double Load::percentage()
{
    double nResult = 0.0;
    
    HostInfo hostInfo;
    
    if(hostInfo.error() == KERN_SUCCESS)
    {
        size_t nTotalTime = 0;
        size_t nUserTime  = 0;
        
        natural_t nCPU;
        natural_t nCPUMax = hostInfo.cpus();
        
        for(nCPU = 0; nCPU < nCPUMax; ++nCPU)
        {
            nUserTime  += hostInfo.user(nCPU);
            nTotalTime += hostInfo.total(nCPU);
        } // for
        
        nResult = 100.0f * double(nUserTime  - mnUserTime) / double(nTotalTime - mnTotalTime);
        
        mnUserTime  = nUserTime;
        mnTotalTime = nTotalTime;
    } // if
    
    return nResult;
} // percentage
