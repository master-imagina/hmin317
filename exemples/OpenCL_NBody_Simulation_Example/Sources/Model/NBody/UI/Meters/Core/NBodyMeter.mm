/*
     File: NBodyMeter.mm
 Abstract: 
 A base utility class for managing performance meters.
 
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

#import <OpenGL/gl.h>

#import "CFCPULoad.h"

#import "GLMConstants.h"
#import "GLMTransforms.h"

#import "HUDMeterImage.h"
#import "HUDMeterTimer.h"

#import "NBodyMeter.h"

static const GLfloat kDefaultSpeed = 0.06f;

@implementation NBodyMeter
{
@private
    BOOL  _isVisible;
    BOOL  _useTimer;
    BOOL  _useHostInfo;
    
    size_t   _max;
    GLsizei  _bound;
    GLfloat  _speed;
    CGSize   _frame;
    CGPoint  _point;
    
    std::string  _label;
    
    BOOL               mbStart;
    GLfloat            mnPosition;
    HUD::Meter::Image* mpMeter;
    HUD::Meter::Timer* mpTimer;
    
    CF::CPU::Load* mpLoad;
}

- (instancetype) init
{
    self = [super init];
    
    if(self)
    {
        _isVisible   = YES;
        _useTimer    = NO;
        _useHostInfo = NO;
        
        _speed = kDefaultSpeed;
        _bound = 0;
        _max   = 0;
        _frame = NSMakeSize(0.0f, 0.0f);
        _point = NSMakePoint(0.0f, 0.0f);
        _label = "";
        
        mbStart    = NO;
        mnPosition = 0.0f;
        
        mpMeter = nullptr;
        mpTimer = nullptr;
        mpLoad  = nullptr;
    } // if
    
    return self;
} // initWithBound

+ (instancetype) meter
{
    return [[[NBodyMeter allocWithZone:[self zone]] init] autorelease];
} // meterWithBound

- (void) dealloc
{
    if(mpTimer != nullptr)
    {
        delete mpTimer;
        
        mpTimer = nullptr;
    } // if
    
    if(mpMeter != nullptr)
    {
        delete mpMeter;
        
        mpMeter = nullptr;
    } // if
    
    if(mpLoad != nullptr)
    {
        delete mpLoad;
        
        mpLoad = nullptr;
    } // if
    
    if(!_label.empty())
    {
        _label.clear();
    } // if
    
    [super dealloc];
} // dealloc

- (void) setFrame:(CGSize)frame
{
    if((frame.width > 0.0f) && (frame.height > 0.0f))
    {
        _frame = frame;
    } // if
} // setFrame

- (void) setIsVisible:(BOOL)isVisible
{
    _isVisible = isVisible;
} // setIsVisible

- (void) setLabel:(std::string)label
{
    if(!label.empty())
    {
        _label = label;
    } // if
} // setLabel

- (void) setValue:(GLdouble)value
{
    mpMeter->setTarget(value);
} // setValue

- (GLdouble) value
{
    return mpMeter->target();
} // value

- (void) toggle
{
    _isVisible = !_isVisible;
} // toggle

- (BOOL) acquire
{
    if(_useHostInfo)
    {
        mpLoad = new (std::nothrow) CF::CPU::Load;
        
        if(!mpLoad)
        {
            NSLog(@">> ERROR: Failed acquiring a CPU utilization query object!");
            
            return false;
        } // catch
    } // if
    
    if(_useTimer)
    {
        mpTimer = new (std::nothrow) HUD::Meter::Timer(20, false);
        
        if(!mpTimer)
        {
            NSLog(@">> ERROR: Failed acquiring a hi-res timer for the meters!");
            
            return false;
        } // catch
    } // if
    
    mpMeter = new (std::nothrow) HUD::Meter::Image(_bound, _bound, _max, _label);
    
    if(!mpMeter)
    {
        NSLog(@">> ERROR: Failed acquiring a meter object!");
        
        return false;
    } // catch
    
    return true;
} // acquire

- (void) reset
{
    if(_useTimer)
    {
        mpTimer->reset();
    } // if
} // reset

- (void) update
{
    if(_useTimer)
    {
        if(!mbStart)
        {
            mpTimer->start();
            
            mbStart = YES;
        } // if
        else
        {
            mpTimer->stop();
            mpTimer->update();
            
            mpMeter->setTarget(mpTimer->persecond());
            
            mpTimer->reset();
        } // else
    } // if
    
    if(_useHostInfo)
    {
        GLdouble nPercentage = mpLoad->percentage();
        
        GLdouble nTargetSrc = mpMeter->target();
        GLdouble nTargetDst = 0.01 * nPercentage + 0.99 * nTargetSrc;
        
        mpMeter->setTarget(nTargetDst);
    } // if
    
    mpMeter->update();
} // update

- (void) draw
{
    glMatrixMode(GL_PROJECTION);
    
    simd::float4x4 ortho = GLM::ortho(0.0f, _frame.width, 0.0f, _frame.height, -1.0f, 1.0f);
    
    GLM::load(true, ortho);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glPushMatrix();
    {
        if(_isVisible)
        {
            if(mnPosition <= (GLM::kHalfPi_f - _speed))
            {
                mnPosition += _speed;
            } // if
        } // if
        else if(mnPosition > 0.0f)
        {
            mnPosition -= _speed;
        } // else if
        
        GLfloat y = 416.0f * (1.0f - std::sinf(mnPosition));
        
        glTranslatef(0.0f, y, 0.0f);
        
        if(mnPosition > 0.0f)
        {
            mpMeter->draw(_point.x, _frame.height - _point.y);
        } // if
    }
    glPopMatrix();
} // draw

@end