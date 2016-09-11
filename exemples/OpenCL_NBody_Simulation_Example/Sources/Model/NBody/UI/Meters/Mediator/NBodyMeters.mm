/*
     File: NBodyMeters.mm
 Abstract: 
 Mediator object for managing multiple hud objects for n-body simulators.
 
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

#import <OpenGL/gl.h>

#import "GLMConstants.h"
#import "GLMTransforms.h"

#import "NBodyMeter.h"
#import "NBodyMeters.h"

@implementation NBodyMeters
{
@private
    size_t           _index;
    size_t           _count;
    NSMutableArray*  mpMeters;
    NBodyMeter*      mpMeter;
}

- (instancetype) initWithCount:(size_t)count
{
    self = [super init];
    
    if(self)
    {
        _index = 0;
        _count = count;
        
        mpMeters = [[NSMutableArray alloc] initWithCapacity:_count];
        
        if(mpMeters)
        {
            size_t i;
            
            for(i = 0; i < _count; ++i)
            {
                mpMeters[i] = [NBodyMeter meter];
            } // for
            
            mpMeter = mpMeters[_index];
        } // if
    } // if
    
    return self;
} // init

- (void) dealloc
{
    if(mpMeters)
    {
        [mpMeters release];
        
        mpMeters = nil;
    } // if
    
    [super dealloc];
} // dealloc

- (void) reset
{
    for(NBodyMeter* pMeter in mpMeters)
    {
        pMeter.value = 0.0;
        
        [pMeter reset];
    } // for
} // reset

- (void) resize:(NSSize)size
{
    for(NBodyMeter* pMeter in mpMeters)
    {
        pMeter.frame = size;
    } // for
} // resize

- (void) show:(BOOL)doShow;
{
    for(NBodyMeter* pMeter in mpMeters)
    {
        pMeter.isVisible = doShow;
    } // for
} // show

- (BOOL) acquire
{
    return [mpMeter acquire];
} // acquire

- (void) toggle
{
    [mpMeter toggle];
} // toggle

- (void) update
{
    [mpMeter update];
} // update

- (void) draw
{
    [mpMeter draw];
} // draw

- (void) draw:(NSArray *)positions
{
    if(positions)
    {
        size_t i = 0;
        
       for(NSValue* position in positions)
       {
           NBodyMeter* pMeter = mpMeters[i];
           
           pMeter.point = position.pointValue;
           
           [pMeter update];
           [pMeter draw];
           
           i++;
       } // for
    } // if
} // draw

- (GLsizei) bound
{
    return mpMeter.bound;
} // bound

- (CGSize) frame
{
    return mpMeter.frame;
} // frame

- (BOOL) useTimer
{
    return mpMeter.useTimer;
} // useTimer

- (BOOL) useHostInfo
{
    return mpMeter.useHostInfo;
} // useHostInfo

- (BOOL) isVisible
{
    return mpMeter.isVisible;
} // isVisible

- (std::string) label
{
    return mpMeter.label;
} // label

- (size_t) max
{
    return mpMeter.max;
} // max

- (CGPoint) point
{
    return mpMeter.point;
} // point

- (GLfloat) speed
{
    return mpMeter.speed;
}// speed

- (GLfloat) value
{
    return mpMeter.value;
} // value

- (void) setBound:(GLsizei)bound
{
    mpMeter.bound = bound;
} // setBound

- (void) setFrame:(CGSize)frame
{
    mpMeter.frame = frame;
} // setFrame

- (void) setUseTimer:(BOOL)useTimer
{
    mpMeter.useTimer = useTimer;
} // setUseTimer

- (void) setUseHostInfo:(BOOL)useHostInfo
{
    mpMeter.useHostInfo = useHostInfo;
} // setUseHostInfo

- (void) setIndex:(size_t)index
{
    _index = (index < _count) ? index : 0;
    
    mpMeter = mpMeters[_index];
} // setIndex

- (void) setIsVisible:(BOOL)isVisible
{
    mpMeter.isVisible = isVisible;
} // setIsVisible

- (void) setLabel:(std::string)label
{
    mpMeter.label = label;
} // setLabel

- (void) setMax:(size_t)max
{
    mpMeter.max = max;
} // setMax

- (void) setPoint:(CGPoint)point
{
    mpMeter.point = point;
} // setPoint

- (void) setSpeed:(GLfloat)speed
{
    mpMeter.speed = speed;
} // setSpeed

- (void) setValue:(GLfloat)value
{
    mpMeter.value = value;
} // setValue

@end
