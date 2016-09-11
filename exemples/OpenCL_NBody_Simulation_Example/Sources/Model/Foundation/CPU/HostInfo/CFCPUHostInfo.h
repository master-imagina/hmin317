/*
     File: CFCPUHostInfo.h
 Abstract: 
 Utility class for acquiring host (cpu) info array.
 
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

#ifndef _CORE_FOUNDATION_CPU_HOST_INFO_H_
#define _CORE_FOUNDATION_CPU_HOST_INFO_H_

#import <mach/mach.h>

#ifdef __cplusplus

namespace CF
{
    namespace CPU
    {
        class HostInfo
        {
        public:
            HostInfo();
            
            HostInfo(const HostInfo& rHostInfo);

            virtual ~HostInfo();
            
            HostInfo& operator=(const HostInfo& rHostInfo);
            
            const kern_return_t error() const;
            
            const processor_flavor_t flavor() const;
            
            const natural_t cpus() const;
            const natural_t size() const;
            
            const natural_t user(const uint32_t& i)   const;
            const natural_t system(const uint32_t& i) const;
            const natural_t idle(const uint32_t& i)   const;
            const natural_t nice(const uint32_t& i)   const;
            
            const size_t total(const uint32_t& i) const;

        private:
            const natural_t state(const uint32_t& i, const natural_t& type) const;
            
            const size_t sum(const uint32_t& i) const;

        private:
            natural_t              mnCount;
            natural_t              mnSize;
            processor_flavor_t     mnFlavor;
            kern_return_t          mnError;
            processor_info_array_t mpInfo;
            mach_msg_type_number_t mnInfo;
        }; // HostInfo
    } // CPU
} // CF

#endif

#endif

