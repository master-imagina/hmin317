/*
     File: NBodySimulationDataGalaxy.mm
 Abstract: 
 Functor for generating random packed data sets for the cpu or gpu bound simulator.
 
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

#import "NBodySimulationDataGalaxy.h"

using namespace NBody::Simulation::Data;

static CFStringRef kGalaxyDataFileExt = CFSTR("dat");

static CFStringRef kGalaxyDataFileName[5] =
{
    CFSTR("bodies_16k"),
    CFSTR("bodies_24k"),
    CFSTR("bodies_32k"),
    CFSTR("bodies_64k"),
    CFSTR("bodies_80k")
};

CF::DataFile* Galaxy::create(const size_t& nBodies)
{
    CFStringRef pFileName = nullptr;
    
    switch(nBodies)
    {
        case 24576:
            pFileName = kGalaxyDataFileName[1];
            break;
            
        case 32768:
            pFileName = kGalaxyDataFileName[2];
            break;
            
        case 65536:
            pFileName = kGalaxyDataFileName[3];
            break;
            
        case 81920:
            pFileName = kGalaxyDataFileName[4];
            break;
            
        case 16384:
        default:
            pFileName = kGalaxyDataFileName[0];
            break;
    } // switch
    
    return new (std::nothrow) CF::DataFile(pFileName, kGalaxyDataFileExt);
} // create

// Acquire the galaxy file using properties
Galaxy::Galaxy(const size_t nBodies)
{
    mnBodies = nBodies;
    mpData   = create(mnBodies);
} // Constructor

// Copy constructor for deep-copy
Galaxy::Galaxy(const Galaxy& rGalaxy)
{
    mnBodies = rGalaxy.mnBodies;
    mpData   = new (std::nothrow) CF::DataFile(*rGalaxy.mpData);
} // Copy Constructor

// Delete the object
Galaxy::~Galaxy()
{
    if(mpData != nullptr)
    {
        delete mpData;
        
        mpData = nullptr;
    } // if
    
    mnBodies = 0;
} // Destructor

// Assignment operator for deep object copy
Galaxy& Galaxy::operator=(const Galaxy& rGalaxy)
{
    if(this != &rGalaxy)
    {
        mnBodies = rGalaxy.mnBodies;
        
        CF::DataFile* pData = new (std::nothrow) CF::DataFile(*rGalaxy.mpData);
        
        if(pData != nullptr)
        {
            if(mpData != nullptr)
            {
                delete mpData;
            } // if
            
            mpData = pData;
        } // if
    } // if
    
    return *this;
} // Assignment Operator

// End-of-File
const bool Galaxy::eof() const
{
    return mpData->eof();
} // eof

// Row count
const size_t Galaxy::rows() const
{
    return mpData->rows();
} // rows

// Column count
const size_t Galaxy::columns() const
{
    return mpData->columns();
} // columns

// File length, or the number of bytes
const size_t Galaxy::length() const
{
    return mpData->length();
} // length

// Current line
const size_t Galaxy::line() const
{
    return mpData->line();
} // line

// Reset the file content pointer to the beginning, past the header
void Galaxy::reset()
{
    mpData->reset();
} // reset

// Float vector from a line in the data file
std::vector<float> Galaxy::floats()
{
    return mpData->floats();
} // floats

// Double vector from a line in the data file
std::vector<double> Galaxy::doubles()
{
    return mpData->doubles();
} // doubles

