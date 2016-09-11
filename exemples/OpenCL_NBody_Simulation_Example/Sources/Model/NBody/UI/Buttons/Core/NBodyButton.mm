/*
     File: NBodyButton.mm
 Abstract: 
 Utility  class for managing a button associated with N-Body simulator.
 
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

#import "GLMConstants.h"
#import "HUDButton.h"
#import "NBodyConstants.h"
#import "NBodyButton.h"

@implementation NBodyButton
{
@private
    BOOL         _isVisible;
    BOOL         _isSelected;
    BOOL         _isItalic;
    CGFloat      _fontSize;
    GLfloat      _speed;
    CGRect       _bounds;
    CGPoint      _position;
    CGPoint      _origin;
    CGSize       _size;
    std::string  _label;
    
    HUD::Button::Image* mpButton;
}

- (instancetype) init
{
    self = [super init];
    
    if(self)
    {
        mpButton    = nullptr;
        _label      = "";
        _isVisible  = YES;
        _isSelected = NO;
        _isItalic   = NO;
        _fontSize   = 24.0f;
        _bounds     = NSMakeRect(0.0f, 0.0f, 0.0f, 0.0f);
        _size       = NSMakeSize(0.0f, 0.0f);
        _position   = NSMakePoint(0.0f, 0.0f);
        _origin     = CGPointMake(0.0f, (_isVisible ? GLM::kHalfPi_f : 0.0f));
        _speed      = NBody::Defaults::kSpeed;
    } // if
    
    return self;
} // init

+ (instancetype) button
{
    return [[[NBodyButton allocWithZone:[self zone]] init] autorelease];
} // button

- (void) dealloc
{
    if(!_label.empty())
    {
        _label.clear();
    } // if
    
    if(mpButton != nullptr)
    {
        delete mpButton;
        
        mpButton = nullptr;
    } // if
    
    [super dealloc];
} // dealloc

- (void) setIsVisible:(BOOL)isVisible
{
    _isVisible = isVisible;
    _origin.y  = _isVisible ? GLM::kHalfPi_f : 0.0f;
} // setIsVisible

- (void) setLabel:(std::string)label
{
    if(!label.empty())
    {
        _label = label;
    } // if
} // setLabel

- (void) setSize:(CGSize)size
{
    _size   = size;
    _bounds = CGRectMake(0.75f * _size.width - 0.5f * NBody::Button::kWidth,
                         NBody::Button::kSpacing,
                         NBody::Button::kWidth,
                         NBody::Button::kHeight);
} // setSize

- (BOOL) acquire
{
    if(mpButton == nullptr)
    {
        mpButton = new (std::nothrow) HUD::Button::Image(_bounds,
                                                         _fontSize,
                                                         _isItalic,
                                                         _label);
    } // if
    
    return mpButton != nullptr;
} // acquire

- (void) toggle
{
    _isVisible = !_isVisible;
} // toggle

- (void) draw
{
    if(mpButton != nullptr)
    {
        if(_isVisible)
        {
            if(_origin.y <= (GLM::kHalfPi_f - _speed))
            {
                _origin.y += _speed;
            } // if
        } // if
        else if(_origin.y > 0.0f)
        {
            _origin.y -= _speed;
        } // else if
        
        GLfloat x = -NBody::Button::kWidth * std::sinf(_origin.x);
        GLfloat y = 100.0f * (std::sinf(_origin.y) - 1.0f);
        
        _position = CGPointMake(x, y);
        
        mpButton->draw(_isSelected, _position, _bounds);
    } // if
} // draw

@end
