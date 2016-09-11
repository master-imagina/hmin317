/*
     File: CFDataFile.h
 Abstract: 
 Utility methods for reading data from a text file.  The file's header contains the number of rows & columns.
 
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

#ifndef _CF_DATA_FILE_H_
#define _CF_DATA_FILE_H_

#import <vector>

#import "CFFile.h"

#ifdef __cplusplus

namespace CF
{
    class DataFile
    {
    public:
        // Constructor for reading from a data file with an absolute pathname
        DataFile(CFStringRef pPathname,
                 const char& nTerminator = '\n');
        
        // Constructor for reading from a data file in an application's bundle
        DataFile(CFStringRef pName,
                 CFStringRef pExt,
                 const char& nTerminator = '\n');
        
        // Constructor for reading from a data file in a domain
        DataFile(const CFSearchPathDomainMask& domain,
                 const CFSearchPathDirectory& directory,
                 CFStringRef pDirName,
                 CFStringRef pFileName,
                 CFStringRef pFileExt,
                 const char& nTerminator = '\n');
        
        // Copy constructor for deep-copy
        DataFile(const DataFile& rDataFile);
        
        // Destructor
        virtual ~DataFile();
        
        // Assignment operator for deep object copy
        DataFile& operator=(const DataFile& rDataFile);
        
        // End-of-File
        const bool eof() const;
        
        // Row count
        const size_t rows() const;
        
        // Column count
        const size_t columns() const;
        
        // File length, or the number of bytes
        const size_t length()  const;
        
        // Current line
        const size_t line() const;

        // Float vector from a line in the data file
        std::vector<float> floats();
        
        // Double vector from a line in the data file
        std::vector<double> doubles();
        
        // Reset the file content pointer to the beginning, past the header
        void reset();
        
    private:
        // Initialize with a input data file
        void initialize(const char& nTerminator,
                        File* mpFile);
        
        // Make a deep-copy from an input data file object
        void clone(const DataFile& rDataFile);
        
        // Clear the ivars
        void clear();
        
        // Delete the file object and clear all other ivars
        void erase();
        
        // Create a new float or double vector from a string
        template<typename T>
        std::vector<T> create(const std::string& rString);
        
        // Read a single line of data from the file 
        template<typename T>
        std::vector<T> readline();
        
    private:
        size_t      mnLength;
        size_t      mnRows;
        size_t      mnColumns;
        size_t      mnLine;
        char        mnTerminator;
        char*       mpBufferPos;
        const char* mpBuffer;
        CF::File*   mpFile;
    }; // DataFile
} // CF

#endif

#endif

