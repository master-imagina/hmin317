/*
     File: CFCPUHostInfo.mm
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

#import "CFProcessorInfoArray.h"
#import "CFCPUHostInfo.h"

using namespace CF::CPU;

static const size_t kSizeInteger = sizeof(natural_t);

HostInfo::HostInfo()
{
    mnCount  = 0;
    mnInfo   = 0;
    mpInfo   = nullptr;
    mnFlavor = PROCESSOR_CPU_LOAD_INFO;
    mnError  = host_processor_info(mach_host_self(), mnFlavor, &mnCount, &mpInfo, &mnInfo);
    mnSize   = kSizeInteger * mnInfo;
} // Constructor

HostInfo::HostInfo(const HostInfo& rHostInfo)
{
    mnCount  = rHostInfo.mnCount;
    mnInfo   = rHostInfo.mnInfo;
    mnSize   = kSizeInteger * rHostInfo.mnInfo;
    mnFlavor = PROCESSOR_CPU_LOAD_INFO;
    mpInfo   = ProcessorInfoArrayCreateCopy(mnSize, rHostInfo.mpInfo, mnError);
} // Copy Constructor

HostInfo::~HostInfo()
{
    ProcessorInfoArrayDelete(mnSize, mpInfo);
    
    mnCount  = 0;
    mnInfo   = 0;
    mnSize   = 0;
    mnFlavor = 0;
    mnError  = 0;
} // Destructor

HostInfo& HostInfo::operator=(const HostInfo& rHostInfo)
{
    if(this != &rHostInfo)
    {
        if((mnInfo != rHostInfo.mnInfo) || (mpInfo == nullptr))
        {
            processor_info_array_t pInfo = ProcessorInfoArrayCreateCopy(rHostInfo.mnSize,
                                                                        rHostInfo.mpInfo,
                                                                        mnError);
            
            if(mnError == KERN_SUCCESS)
            {
                mnError = ProcessorInfoArrayDelete(mnSize, mpInfo);
                
                if(mnError == KERN_SUCCESS)
                {
                    mpInfo = pInfo;
                } // if
                else
                {
                    ProcessorInfoArrayDelete(mnSize, pInfo);
                } // else
            } // if
        } // if
        else
        {
            mnError = ProcessorInfoArrayCopy(rHostInfo.mnSize, rHostInfo.mpInfo, mpInfo);
        } // else
        
        if(mnError == KERN_SUCCESS)
        {
            mnSize   = rHostInfo.mnSize;
            mnCount  = rHostInfo.mnCount;
            mnInfo   = rHostInfo.mnInfo;
            mnFlavor = PROCESSOR_CPU_LOAD_INFO;
        } // if
    } // if
    
    return *this;
} // Assignment Operator

const kern_return_t HostInfo::error() const
{
    return mnError;
} // error

const processor_flavor_t HostInfo::flavor() const
{
    return mnFlavor;
} // flavor

const natural_t HostInfo::cpus() const
{
    return mnCount;
} // cpus

const natural_t HostInfo::size() const
{
    return mnSize;
} // size

const natural_t HostInfo::state(const uint32_t& i, const natural_t& type) const
{
    return (i < mnCount) ? mpInfo[CPU_STATE_MAX * i + type] : 0;
} // state

const natural_t HostInfo::user(const uint32_t& i) const
{
    return (mpInfo != nullptr) ? state(i, CPU_STATE_USER) : 0;
} // user

const natural_t HostInfo::system(const uint32_t& i) const
{
    return (mpInfo != nullptr) ? state(i, CPU_STATE_SYSTEM) : 0;
} // system

const natural_t HostInfo::idle(const uint32_t& i) const
{
    return (mpInfo != nullptr) ? state(i, CPU_STATE_IDLE) : 0;
} // idle

const natural_t HostInfo::nice(const uint32_t& i) const
{
    return (mpInfo != nullptr) ? state(i, CPU_STATE_NICE) : 0;
} // nice

const size_t HostInfo::sum(const uint32_t& i) const
{
    natural_t nSum = 0;
    
    if(i < mnCount)
    {
        natural_t nOffset = CPU_STATE_MAX * i;
        natural_t nUser   = mpInfo[nOffset + CPU_STATE_USER];
        natural_t nSytem  = mpInfo[nOffset + CPU_STATE_SYSTEM];
        natural_t nIde    = mpInfo[nOffset + CPU_STATE_IDLE];
        natural_t nNice   = mpInfo[nOffset + CPU_STATE_NICE];
        
        nSum = nSytem + nIde + nNice + nUser;
    } // if
    
    return nSum;
} // sum

const size_t HostInfo::total(const uint32_t& i) const
{
    return (mpInfo != nullptr) ? sum(i) : 0;
} // total

