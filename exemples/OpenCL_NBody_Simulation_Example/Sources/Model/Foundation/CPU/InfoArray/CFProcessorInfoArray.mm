/*
     File: CFProcessorInfoArray.mm
 Abstract: 
 Utility methods for processor info array management.
 
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

#include <mach/vm_map.h>

#import "CFProcessorInfoArray.h"

typedef vm_address_t * vm_address_ref;

processor_info_array_t CF::ProcessorInfoArrayCreate(const natural_t& nSize,
                                                    kern_return_t& err)
{
    processor_info_array_t pInfo = nullptr;
    
    err = (nSize) ? KERN_SUCCESS : KERN_INVALID_ARGUMENT;
    
    if(err == KERN_SUCCESS)
    {
        err = vm_allocate(mach_task_self(),
                          vm_address_ref(&pInfo),
                          nSize,
                          VM_FLAGS_ANYWHERE);
    } // if
    
    return pInfo;
} // ProcessorInfoArrayCreate

processor_info_array_t CF::ProcessorInfoArrayCreateCopy(const natural_t& nSizeDst,
                                                        processor_info_array_t pInfoSrc,
                                                        kern_return_t& err)
{
    processor_info_array_t pInfoDst = nullptr;
    
    err = (nSizeDst) ? KERN_SUCCESS : KERN_INVALID_ARGUMENT;

    if(err == KERN_SUCCESS)
    {
        err = vm_allocate(mach_task_self(),
                          vm_address_ref(&pInfoDst),
                          nSizeDst,
                          VM_FLAGS_ANYWHERE);
        
        if(err == KERN_SUCCESS)
        {
            err = vm_copy(mach_task_self(),
                          vm_address_t(pInfoSrc),
                          nSizeDst,
                          vm_address_t(pInfoDst));
        } // if
    } // if
    
    return pInfoDst;
} // ProcessorInfoArrayCreateCopy

kern_return_t CF::ProcessorInfoArrayCopy(const natural_t& nSize,
                                         processor_info_array_t pInfoSrc,
                                         processor_info_array_t pInfoDst)
{
    kern_return_t err = (nSize) ? KERN_SUCCESS : KERN_INVALID_ARGUMENT;
    
    if(err == KERN_SUCCESS)
    {
        err = vm_copy(mach_task_self(),
                      vm_address_t(pInfoSrc),
                      nSize,
                      vm_address_t(pInfoDst));
    } // if
    
    return err;
} // ProcessorInfoArrayCopy

kern_return_t CF::ProcessorInfoArrayDelete(const natural_t& nSize,
                                           processor_info_array_t pInfo)
{
    kern_return_t err = (nSize) ? KERN_SUCCESS : KERN_INVALID_ARGUMENT;
    
    if(err == KERN_SUCCESS)
    {
        err = vm_deallocate(mach_task_self(), vm_address_t(pInfo), nSize);
        
        pInfo = nullptr;
    } // if
    
    return err;
} // ProcessorInfoArrayDelete
