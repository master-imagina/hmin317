/*
     File: CFFile.h
 Abstract: 
 Utility methods for managing input file streams.
 
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


#ifndef _CF_FILE_H_
#define _CF_FILE_H_

#import <iostream>
#import <string>

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>

#ifdef __cplusplus

typedef NSSearchPathDirectory  CFSearchPathDirectory;
typedef NSSearchPathDomainMask CFSearchPathDomainMask;

namespace CF
{
    class File
    {
    public:
        // Constructor for reading a file with an absolute pathname
        File(CFStringRef pPathname);
        
        // Constructor for reading a file in an application's bundle
        File(CFStringRef pName, CFStringRef pExt);
        
        // Constructor for reading a file in a domain
        File(const CFSearchPathDomainMask& domain,
             const CFSearchPathDirectory& directory,
             CFStringRef pDirName,
             CFStringRef pFileName,
             CFStringRef pFileExt);
        
        // Constructor for reading a file using a URL
        File(CFURLRef pURL);
        
        // Copy constructor for deep-copy
        File(const File& rFile);
        
        // Delete the object
        virtual ~File();
        
        // Assignment operator for deep object copy
        File& operator=(const File& rFile);
        
        // Assignment operator for property list deep-copy
        File& operator=(CFPropertyListRef pPListSrc);
        
        // Accessor to return a c-string representation of the read file
        const char* cstring() const;
        
        // Accessor, if the read file was a data file
        const uint8_t* bytes() const;
        
        // Length of the data or the string
        const CFIndex length() const;
        
        // Options used for reading the property list
        const CFOptionFlags options() const;
        
        // Format used for reading the property list
        const CFPropertyListFormat format() const;
        
        // Domain mask for searching for a file
        const CFSearchPathDomainMask domain() const;
        
        // Directory enumerated type for seaching for a file
        const CFSearchPathDirectory directory() const;
        
        // File's representation as data
        CFDataRef data() const;
        
        // Error associated with creating a property list
        CFStringRef error() const;
        
        // Property list
        CFPropertyListRef plist() const;
        
        // File's url
        CFURLRef url() const;
        
        // Query for if the file was a property list
        const bool isPList() const;
        
        // Create a text string from the contents of a file
        std::string string();
        
        // Create a cf string from the contents of a file
        CFStringRef cfstring();
        
        // Write to the original location
        bool write();
        
        // Write the file to a location using an absolute pathname
        bool write(CFStringRef pPathname);
        
        // Write the file to the application's bundle
        bool write(CFStringRef pName, CFStringRef pExt);
        
    private:
        // Initialize all instance variables
        void initialize();
        
        // Create and initialize all ivars
        void acquire(const bool& isPList);
        
        // Create a deep-copy
        void clone(const File& rFile);
        
        // Create a deep-copy of the property list
        void clone(CFPropertyListRef pPListSrc);
        
        // Write the file to a location using url
        bool write(CFURLRef pURL);
        
    private:
        CFIndex                 mnLength;
        CFURLRef                mpURL;
        CFDataRef               mpData;
        CFPropertyListRef       mpPList;
        CFPropertyListFormat    mnFormat;
        CFOptionFlags           mnOptions;
        CFStringRef             mpError;
        CFSearchPathDirectory   mnDirectory;
        CFSearchPathDomainMask  mnDomain;
    };
} // CF

#endif

#endif

