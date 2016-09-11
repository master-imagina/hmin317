/*
     File: CTFrame.mm
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

#pragma mark -
#pragma mark Private - Headers

#import <OpenGL/gl.h>

#import "CFText.h"
#import "CTFrame.h"

#pragma mark -
#pragma mark Private - Namespaces

using namespace CT;

#pragma mark -
#pragma mark Private - Constants

static const CGSize  kCTFrameDefaultMaxSz = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);

#pragma mark -
#pragma mark Private - Utilities - Constructor - Framesetter

CTFramesetterRef Frame::create(const std::string& rText,
                               const std::string& rFont,
                               const GLfloat& nFontSize,
                               const CTTextAlignment& nTextAlign)
{
    CTFramesetterRef pFrameSetter = nullptr;
    
    CF::TextRef pText = CF::TextCreate(rText, rFont, nFontSize, nTextAlign);
    
    if(pText != nullptr)
    {
        m_Range = CFRangeMake(0, CFAttributedStringGetLength(pText));
        
        pFrameSetter = CTFramesetterCreateWithAttributedString(pText);
        
        CFRelease(pText);
    } // if
    
    return pFrameSetter;
} // create

#pragma mark -
#pragma mark Private - Utilities - Constructors - Frames

CTFrameRef Frame::create(CTFramesetterRef pFrameSetter)
{
    CTFrameRef pFrame = nullptr;
    
    if(pFrameSetter != nullptr)
    {
        CGMutablePathRef pPath = CGPathCreateMutable();
        
        if(pPath != nullptr)
        {
            CGPathAddRect(pPath, nullptr, m_Bounds);
            
            pFrame = CTFramesetterCreateFrame(pFrameSetter,
                                              m_Range,
                                              pPath,
                                              nullptr);
            
            CFRelease(pPath);
        } // if
    } // if
    
    return pFrame;
} // create

CTFrameRef Frame::create(const CGPoint& rOrigin,
                         const CGSize& rSize,
                         CTFramesetterRef pFrameSetter)
{
    m_Bounds = CGRectMake(rOrigin.x,
                          rOrigin.y,
                          rSize.width,
                          rSize.height);
    
    return create(pFrameSetter);
} // create

CTFrameRef Frame::create(const GLsizei& nWidth,
                         const GLsizei& nHeight,
                         CTFramesetterRef pFrameSetter)
{
    m_Bounds = CGRectMake(0.0f,
                          0.0f,
                          CGFloat(nWidth),
                          CGFloat(nHeight));
    
    return create(pFrameSetter);
} // create

CTFrameRef Frame::create(const std::string& rText,
                         const std::string& rFont,
                         const GLfloat& nFontSize,
                         const CGPoint& rOrigin,
                         const CTTextAlignment& nTextAlign)
{
    CTFrameRef pFrame = nullptr;
    
    if(!rText.empty())
    {
        CTFramesetterRef pFrameSetter = create(rText, rFont, nFontSize, nTextAlign);
        
        if(pFrameSetter != nullptr)
        {
            CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(pFrameSetter,
                                                                       m_Range,
                                                                       nullptr,
                                                                       kCTFrameDefaultMaxSz,
                                                                       nullptr);
            
            pFrame = create(rOrigin, size, pFrameSetter);
            
            CFRelease(pFrameSetter);
        } // if
    } // if
    
    return pFrame;
} // create

CTFrameRef Frame::create(const std::string& rText,
                         const std::string& rFont,
                         const GLfloat& nFontSize,
                         const GLsizei& nWidth,
                         const GLsizei& nHeight,
                         const CTTextAlignment& nTextAlign)
{
    CTFrameRef pFrame = nullptr;
    
    if(!rText.empty())
    {
        CTFramesetterRef pFrameSetter = create(rText, rFont, nFontSize, nTextAlign);
        
        if(pFrameSetter != nullptr)
        {
            pFrame = create(nWidth, nHeight, pFrameSetter);
            
            CFRelease(pFrameSetter);
        } // if
    } // if
    
    return pFrame;
} // draw

#pragma mark -
#pragma mark Private - Utilities - Defaults

void Frame::defaults()
{
    mpFrame  = nullptr;
    m_Range  = CFRangeMake(0, 0);
    m_Bounds = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
} // defaults

#pragma mark -
#pragma mark Public - Constructors

// Create a frame with bounds derived from the text size.
Frame::Frame(const std::string& rText,
             const std::string& rFont,
             const GLfloat& nFontSize,
             const CGPoint& rOrigin,
             const CTTextAlignment& nTextAlign)
{
    mpFrame = create(rText, rFont, nFontSize, rOrigin, nTextAlign);
} // Constructor

// Create a frame with bounds derived from the input width and height.
Frame::Frame(const std::string& rText,
             const std::string& rFont,
             const GLfloat& nFontSize,
             const GLsizei& nWidth,
             const GLsizei& nHeight,
             const CTTextAlignment& nTextAlign)
{
    mpFrame = create(rText, rFont, nFontSize, nWidth, nHeight, nTextAlign);
} // Constructor

// Create a frame with bounds derived from the text size using
// helvetica bold or helvetica bold oblique font.
Frame::Frame(const std::string& rText,
             const CGFloat& nFontSize,
             const bool& bIsItalic,
             const CGPoint& rOrigin,
             const CTTextAlignment& nTextAlign)
{
    std::string font = bIsItalic ? "Helvetica-BoldOblique" : "Helvetica-Bold";
    
    mpFrame = create(rText, font, nFontSize, rOrigin, nTextAlign);
} // Constructor

// Create a frame with bounds derived from input width and height,
// and using helvetica bold or helvetica bold oblique font.
Frame::Frame(const std::string& rText,
             const CGFloat& nFontSize,
             const bool& bIsItalic,
             const GLsizei& nWidth,
             const GLsizei& nHeight,
             const CTTextAlignment& nTextAlign)
{
    std::string font = bIsItalic ? "Helvetica-BoldOblique" : "Helvetica-Bold";
    
    mpFrame = create(rText, font, nFontSize, nWidth, nHeight, nTextAlign);
} // Constructor

#pragma mark -
#pragma mark Public - Destructor

Frame::~Frame()
{
    if(mpFrame != nullptr)
    {
        CFRelease(mpFrame);
        
        mpFrame = nullptr;
    } // if
} // Destructor

#pragma mark -
#pragma mark Public - Utlities

void Frame::draw(CGContextRef pContext)
{
    if(pContext != nullptr)
    {
        CTFrameDraw(mpFrame, pContext);
    } // if
} // draw

#pragma mark -
#pragma mark Public - Accessors

const CGRect& Frame::bounds() const
{
    return m_Bounds;
} // bounds

const CFRange& Frame::range() const
{
    return m_Range;
} // range
