/*
     File: CGBitmap.mm
 Abstract: 
 Utility methods acquiring CG bitmap contexts.
 
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

#import <cmath>
#import <iostream>

#import "CGBitmap.h"

#pragma mark -
#pragma mark Private - Namespaces

using namespace CG;

#pragma mark -
#pragma mark Private - Utilities

static CGContextRef CGBitmapCreateFromImage(CGImageRef pImage)
{
    CGContextRef pContext = nullptr;
    
    if(pImage != nullptr)
    {
        CGColorSpaceRef pColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
        
        if(pColorSpace != nullptr)
        {
            size_t       nWidth    = CGImageGetWidth(pImage);
            size_t       nHeight   = CGImageGetHeight(pImage);
            size_t       nRowBytes = 4 * nWidth;
            CGBitmapInfo nBMPI     = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
            
            pContext = CGBitmapContextCreate(nullptr,
                                             nWidth,
                                             nHeight,
                                             8,
                                             nRowBytes,
                                             pColorSpace,
                                             nBMPI);
            
            if(pContext != nullptr)
            {
                CGContextDrawImage(pContext, CGRectMake(0, 0, nWidth, nHeight), pImage);
            } // if
            
            CFRelease(pColorSpace);
        } // if
    } // if
    
    return pContext;
} // CGBitmapCreateFromImage

static CGImageRef CGBitmapCreateImage(CFStringRef pName,
                                      CFStringRef pExt)
{
    CGImageRef pImage = nullptr;
    
    if((pName != nullptr) && (pExt != nullptr))
    {
        CFBundleRef pBundle = CFBundleGetMainBundle();
        
        if(pBundle != nullptr)
        {
            CFURLRef pURL = CFBundleCopyResourceURL(pBundle, pName, pExt, nullptr);
            
            if(pURL != nullptr)
            {
                CGImageSourceRef pSource = CGImageSourceCreateWithURL(pURL, nullptr);
                
                if(pSource != nullptr)
                {
                    pImage = CGImageSourceCreateImageAtIndex(pSource, 0, nullptr);
                    
                    CFRelease(pSource);
                } // if
                
                CFRelease(pURL);
            } // if
        } // if
    } // if
    
    return pImage;
} // CGBitmapCreateFromImage

static CGContextRef CGBitmapCreateCopy(const CGContextRef pContextSrc)
{
    CGContextRef pContextDst = nullptr;
    
    if(pContextSrc != nullptr)
    {
        CGImageRef pImage = CGBitmapContextCreateImage(pContextSrc);
        
        if(pImage != nullptr)
        {
            pContextDst = CGBitmapCreateFromImage(pImage);
            
            CFRelease(pImage);
        } // if
    } // if
    
    return pContextDst;
} // CGBitmapCreateCopy

#pragma mark -
#pragma mark Public - Interfaces

Bitmap::Bitmap(CFStringRef pName,
               CFStringRef pExt)
{
    mpContext  = nullptr;
    mnWidth    = 0;
    mnHeight   = 0;
    mnRowBytes = 0;
    mnBMPI     = 0;
    
    CGImageRef pImage = CGBitmapCreateImage(pName, pExt);
    
    if(pImage != nullptr)
    {
        mnWidth    = CGImageGetWidth(pImage);
        mnHeight   = CGImageGetHeight(pImage);
        mnRowBytes = 4 * mnWidth;
        mnBMPI     = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
        mpContext  = CGBitmapCreateFromImage(pImage);
        
        CFRelease(pImage);
    } // if
} // Constructor

Bitmap::Bitmap(const Bitmap::Bitmap& rBitmap)
{
    mpContext = CGBitmapCreateCopy(rBitmap.mpContext);
    
    if(mpContext != nullptr)
    {
        mnWidth    = rBitmap.mnWidth;
        mnHeight   = rBitmap.mnHeight;
        mnRowBytes = rBitmap.mnRowBytes;
        mnBMPI     = rBitmap.mnBMPI;
    } // if
} // Copy Constructor

Bitmap::Bitmap(const Bitmap * const pBitmap)
{
    if(pBitmap != nullptr)
    {
        mpContext = CGBitmapCreateCopy(pBitmap->mpContext);
        
        if(mpContext != nullptr)
        {
            mnWidth    = pBitmap->mnWidth;
            mnHeight   = pBitmap->mnHeight;
            mnRowBytes = pBitmap->mnRowBytes;
            mnBMPI     = pBitmap->mnBMPI;
        } // if
    } // if
} // Copy Constructor

Bitmap::~Bitmap()
{
    CGContextRelease(mpContext);
} // Destructor

Bitmap& Bitmap::operator=(const Bitmap& rBitmap)
{
    if(this != &rBitmap)
    {
        CGContextRef pContext = CGBitmapCreateCopy(rBitmap.mpContext);
        
        if(pContext != nullptr)
        {
            CGContextRelease(mpContext);
            
            mnWidth    = rBitmap.mnWidth;
            mnHeight   = rBitmap.mnHeight;
            mnRowBytes = rBitmap.mnRowBytes;
            mnBMPI     = rBitmap.mnBMPI;
            mpContext  = pContext;
        } // if
    } // if
    
    return *this;
} // Operator =

bool Bitmap::copy(const CGContextRef pContext)
{
    bool bSuccess = pContext != nullptr;
    
    if(bSuccess)
    {
        size_t        nWidth    = CGBitmapContextGetWidth(pContext);
        size_t        nHeight   = CGBitmapContextGetHeight(pContext);
        size_t        nRowBytes = CGBitmapContextGetBytesPerRow(pContext);
        CGBitmapInfo  nBMPI     = CGBitmapContextGetBitmapInfo(pContext);
        
        bSuccess =
        ( nWidth    == mnWidth    )
        &&  ( nHeight   == mnHeight   )
        &&  ( nRowBytes == mnRowBytes )
        &&  ( nBMPI     == mnBMPI     );
        
        if(bSuccess)
        {
            const void *pDataSrc = CGBitmapContextGetData(pContext);
            
            void *pDataDst = CGBitmapContextGetData(mpContext);
            
            bSuccess = (pDataSrc != nullptr) && (pDataDst != nullptr);
            
            if(bSuccess)
            {
                const size_t nSize = mnRowBytes * mnHeight;
                
                std::memcpy(pDataDst, pDataSrc, nSize);
            } // if
        } // if
    } // if
    
    return bSuccess;
} // copy

const size_t& Bitmap::width() const
{
    return mnWidth;
} // width

const size_t& Bitmap::height() const
{
    return mnHeight;
} // height

const size_t& Bitmap::rowBytes() const
{
    return mnRowBytes;
} // rowBytes

const CGBitmapInfo& Bitmap::bitmapInfo() const
{
    return mnBMPI;
} // bitmapInfo

const CGContextRef Bitmap::context() const
{
    return mpContext;
} // context

void* Bitmap::data()
{
    void *pData = nullptr;
    
    if(mpContext != nullptr)
    {
        pData = CGBitmapContextGetData(mpContext);
    } // if
    
    return pData;
} // data
