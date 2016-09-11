/*
     File: NBodyButtons.mm
 Abstract: 
 Mediator object for managing buttons associated with N-Body simulator types.
 
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

#import "NBodyButton.h"
#import "NBodyButtons.h"

@implementation NBodyButtons
{
@private
    size_t          _index;
    size_t          _count;
    NSMutableArray* mpButtons;
    NBodyButton*    mpButton;
}

- (instancetype) initWithCount:(size_t)count
{
    self = [super init];
    
    if(self)
    {
        _index = 0;
        _count = count;
        
        mpButtons = [[NSMutableArray alloc] initWithCapacity:_count];
        
        if(mpButtons)
        {
            size_t i;
            
            for(i = 0; i < _count; ++i)
            {
                mpButtons[i] = [NBodyButton button];
            } // for
            
            mpButton = mpButtons[_index];
        } // if
    } // if
    
    return self;
} // init

- (void) dealloc
{
    if(mpButtons)
    {
        [mpButtons release];
        
        mpButtons = nil;
    } // if
    
    [super dealloc];
} // dealloc

- (void) setIndex:(size_t)index
{
    _index = (index < _count) ? index : 0;
    
    mpButton = mpButtons[_index];
} // setIndex

- (BOOL) isItalic
{
    return mpButton.isItalic;
} // isItalic

- (BOOL) isSelected
{
    return mpButton.isSelected;
} // isSelected

- (BOOL) isVisible
{
    return mpButton.isVisible;
} // isVisible

- (std::string) label
{
    return mpButton.label;
} // label

- (CGFloat) fontSize
{
    return mpButton.fontSize;
} // fontSize

- (GLfloat) speed
{
    return mpButton.speed;
} // speed

- (CGRect) bounds
{
    return mpButton.bounds;
} // bounds

- (CGPoint) origin
{
    return mpButton.origin;
} // origin

- (CGPoint) position
{
    return mpButton.position;
} // position

- (CGSize) size
{
    return mpButton.size;
} // size

- (void) setLabel:(std::string)label
{
    mpButton.label = label;
} // setLabel

- (void) setIsItalic:(BOOL)isItalic
{
    mpButton.isItalic = isItalic;
} // setIsItalic

- (void) setIsSelected:(BOOL)isSelected
{
    mpButton.isSelected = isSelected;
} // setIsSelected

- (void) setIsVisible:(BOOL)isVisible
{
    mpButton.isVisible = isVisible;
} // setIsVisible

- (void) setFontSize:(CGFloat)fontSize
{
    mpButton.fontSize = fontSize;
} // fontSize

- (void) setSpeed:(GLfloat)speed
{
    mpButton.speed = speed;
} // setSpeed

- (void) setOrigin:(CGPoint)origin
{
    mpButton.origin = origin;
} // setOrigin

- (void) setSize:(CGSize)size
{
    mpButton.size = size;
} // setSize

- (BOOL) acquire
{
    return [mpButton acquire];
} // acquire

- (void) toggle
{
    [mpButton toggle];
} // toggle

- (void) draw
{
    [mpButton draw];
} // draw

@end