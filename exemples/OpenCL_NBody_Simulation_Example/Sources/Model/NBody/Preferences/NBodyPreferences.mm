/*
     File: NBodyPreferences.mm
 Abstract: 
 Utility class for managing application's preferences and settings.
 
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

#import "NSFile.h"

#import "NBodyConstants.h"
#import "NBodyPreferences.h"

#pragma mark -

// Keys for the preferences dictionary                 // For values
NSString* kNBodyPrefDemos         = @"demos";          // Signed integer 64
NSString* kNBodyPrefDemoType      = @"demoType";       // Unsigned Integer 32
NSString* kNBodyPrefBodies        = @"bodies";         // Unsigned Integer 32
NSString* kNBodyPrefConfig        = @"config";         // Unsigned Integer 32
NSString* kNBodyPrefMaxUpdates    = @"maxUpdates";     // Unsigned Long
NSString* kNBodyPrefMaxFrameRate  = @"maxFramerate";   // Unsigned Long
NSString* kNBodyPrefMaxPerf       = @"maxPerf";        // Unsigned Long
NSString* kNBodyPrefMaxCPU        = @"maxCPU";         // Unsigned Long
NSString* kNBodyPrefRotateX       = @"rotateX";        // Double
NSString* kNBodyPrefRotateY       = @"rotateY";        // Double
NSString* kNBodyPrefSizeWidth     = @"width";          // Double
NSString* kNBodyPrefSizeHeight    = @"height";         // Double
NSString* kNBodyPrefClearColor    = @"clearColor";     // Float
NSString* kNBodyPrefStarScale     = @"starScale";      // Float
NSString* kNBodyPrefViewDistance  = @"viewDistance";   // Float
NSString* kNBodyPrefTimeStep      = @"timeStep";       // Float
NSString* kNBodyPrefClusterScale  = @"clusterScale";   // Float
NSString* kNBodyPrefVelocityScale = @"velocityScale";  // Float
NSString* kNBodyPrefSoftening     = @"softening";      // Float
NSString* kNBodyPrefDamping       = @"damping";        // Float
NSString* kNBodyPrefPointSize     = @"pointSize";      // Float
NSString* kNBodyPrefFullScreen    = @"fullscreen";     // BOOL
NSString* kNBodyPrefIsGPUOnly     = @"isGPUOnly";      // BOOL
NSString* kNBodyPrefShowUpdates   = @"showUpdates";    // BOOL
NSString* kNBodyPrefShowFrameRate = @"showFramerate";  // BOOL
NSString* kNBodyPrefShowPerf      = @"showPerf";       // BOOL
NSString* kNBodyPrefShowDock      = @"showDock";       // BOOL
NSString* kNBodyPrefShowCPU       = @"showCPU";        // BOOL

@implementation NBodyPreferences
{
@private
    int64_t _demos;
    
    uint32_t _demoType;
    uint32_t _config;
    uint32_t _bodies;
    
    size_t _maxUpdates;
    size_t _maxFramerate;
    size_t _maxPerf;
    size_t _maxCPU;
    
    NSPoint _rotate;
    NSSize  _size;
    
    float  _timeStep;
    float  _clusterScale;
    float  _velocityScale;
    float  _softening;
    float  _damping;
    float  _pointSize;
    float  _starScale;
    float  _viewDistance;
    float  _clearColor;
    
    BOOL  _isGPUOnly;
    BOOL  _fullscreen;
    BOOL  _showUpdates;
    BOOL  _showFramerate;
    BOOL  _showPerf;
    BOOL  _showDock;
    BOOL  _showCPU;
    
    NSString* _identifier;
    
    NSMutableDictionary* mpPreferences;
    
    NSFile* mpFile;
}

- (void) _setLongLongValue:(int64_t &)value
                      with:(NSNumber *)pNumber
{
    if(pNumber)
    {
        value = pNumber.longLongValue;
    } // if
} // _setLongLongValue

- (void) _setUnsignedIntValue:(uint32_t &)value
                         with:(NSNumber *)pNumber
{
    if(pNumber)
    {
        value = pNumber.unsignedIntValue;
    } // if
} // _setUnsignedIntValue

- (void) _setUnsignedLongValue:(size_t &)value
                          with:(NSNumber *)pNumber
{
    if(pNumber)
    {
        value = pNumber.unsignedLongValue;
    } // if
} // _setUnsignedLongValue

- (void) _setDoubleValue:(double &)value
                    with:(NSNumber *)pNumber
{
    if(pNumber)
    {
        value = pNumber.doubleValue;
    } // if
} // _setDoubleValue

- (void) _setFloatValue:(float &)value
                   with:(NSNumber *)pNumber
{
    if(pNumber)
    {
        value = pNumber.floatValue;
    } // if
} // _setFloatValue

- (void) _setBoolValue:(BOOL &)value
                  with:(NSNumber *)pNumber
{
    if(pNumber)
    {
        value = pNumber.floatValue;
    } // if
} // _setBoolValue

- (BOOL) _setPreferences:(NSDictionary *)pPrefs
{
    BOOL success = pPrefs.count > 0;
    
    if(success)
    {
        [self _setLongLongValue:_demos            with:pPrefs[kNBodyPrefDemos]];
        [self _setUnsignedIntValue:_demoType      with:pPrefs[kNBodyPrefDemoType]];
        [self _setUnsignedIntValue:_bodies        with:pPrefs[kNBodyPrefBodies]];
        [self _setUnsignedIntValue:_config        with:pPrefs[kNBodyPrefConfig]];
        [self _setUnsignedLongValue:_maxUpdates   with:pPrefs[kNBodyPrefMaxUpdates]];
        [self _setUnsignedLongValue:_maxFramerate with:pPrefs[kNBodyPrefMaxFrameRate]];
        [self _setUnsignedLongValue:_maxPerf      with:pPrefs[kNBodyPrefMaxPerf]];
        [self _setUnsignedLongValue:_maxCPU       with:pPrefs[kNBodyPrefMaxCPU]];
        [self _setDoubleValue:_rotate.x           with:pPrefs[kNBodyPrefRotateX]];
        [self _setDoubleValue:_rotate.y           with:pPrefs[kNBodyPrefRotateY]];
        [self _setDoubleValue:_size.width         with:pPrefs[kNBodyPrefSizeWidth]];
        [self _setDoubleValue:_size.height        with:pPrefs[kNBodyPrefSizeHeight]];
        [self _setFloatValue:_clearColor          with:pPrefs[kNBodyPrefClearColor]];
        [self _setFloatValue:_starScale           with:pPrefs[kNBodyPrefStarScale]];
        [self _setFloatValue:_viewDistance        with:pPrefs[kNBodyPrefViewDistance]];
        [self _setFloatValue:_timeStep            with:pPrefs[kNBodyPrefTimeStep]];
        [self _setFloatValue:_clusterScale        with:pPrefs[kNBodyPrefClusterScale]];
        [self _setFloatValue:_velocityScale       with:pPrefs[kNBodyPrefVelocityScale]];
        [self _setFloatValue:_softening           with:pPrefs[kNBodyPrefSoftening]];
        [self _setFloatValue:_damping             with:pPrefs[kNBodyPrefDamping]];
        [self _setFloatValue:_pointSize           with:pPrefs[kNBodyPrefPointSize]];
        [self _setBoolValue:_fullscreen           with:pPrefs[kNBodyPrefFullScreen]];
        [self _setBoolValue:_isGPUOnly            with:pPrefs[kNBodyPrefIsGPUOnly]];
        [self _setBoolValue:_showUpdates          with:pPrefs[kNBodyPrefShowUpdates]];
        [self _setBoolValue:_showFramerate        with:pPrefs[kNBodyPrefShowFrameRate]];
        [self _setBoolValue:_showCPU              with:pPrefs[kNBodyPrefShowCPU]];
        [self _setBoolValue:_showPerf             with:pPrefs[kNBodyPrefShowPerf]];
        [self _setBoolValue:_showDock             with:pPrefs[kNBodyPrefShowDock]];
    } // if
    
    return success;
} // _setPreferences

- (NSMutableDictionary *) _newPreferences
{
    _demos         = 7;
    _demoType      = 1;
    _bodies        = NBody::Bodies::kCount;
    _config        = NBody::Config::eConfigShell;
    _maxFramerate  = 120;
    _maxUpdates    = 120;
    _maxCPU        = 100;
    _maxPerf       = 1400;
    _rotate.x      = 0.0f;
    _rotate.y      = 0.0f;
    _size.width    = NBody::Window::kWidth;
    _size.height   = NBody::Window::kHeight;
    _clearColor    = 1.0f;
    _starScale     = 1.0f;
    _viewDistance  = 30.0f;
    _timeStep      = NBody::Scale::kTime * 0.016f;
    _clusterScale  = 1.54f;
    _velocityScale = 8.0f;
    _softening     = NBody::Scale::kSoftening * 0.1f;
    _damping       = 1.0f;
    _pointSize     = 1.0f;
    _fullscreen    = NO;
    _isGPUOnly     = NO;
    _showUpdates   = NO;
    _showFramerate = NO;
    _showCPU       = NO;
    _showPerf      = YES;
    _showDock      = YES;
    
    NSArray* pKeys = @[kNBodyPrefDemos,
                       kNBodyPrefDemoType,
                       kNBodyPrefBodies,
                       kNBodyPrefConfig,
                       kNBodyPrefMaxUpdates,
                       kNBodyPrefMaxFrameRate,
                       kNBodyPrefMaxCPU,
                       kNBodyPrefMaxPerf,
                       kNBodyPrefRotateX,
                       kNBodyPrefRotateY,
                       kNBodyPrefSizeWidth,
                       kNBodyPrefSizeHeight,
                       kNBodyPrefClearColor,
                       kNBodyPrefStarScale,
                       kNBodyPrefViewDistance,
                       kNBodyPrefTimeStep,
                       kNBodyPrefClusterScale,
                       kNBodyPrefVelocityScale,
                       kNBodyPrefSoftening,
                       kNBodyPrefDamping,
                       kNBodyPrefPointSize,
                       kNBodyPrefFullScreen,
                       kNBodyPrefIsGPUOnly,
                       kNBodyPrefShowUpdates,
                       kNBodyPrefShowFrameRate,
                       kNBodyPrefShowCPU,
                       kNBodyPrefShowPerf,
                       kNBodyPrefShowDock];
    
    NSArray* pObjects = @[@(_demos),
                          @(_demoType),
                          @(_bodies),
                          @(_config),
                          @(_maxUpdates),
                          @(_maxFramerate),
                          @(_maxCPU),
                          @(_maxPerf),
                          @(_rotate.x),
                          @(_rotate.y),
                          @(_size.width),
                          @(_size.height),
                          @(_clearColor),
                          @(_starScale),
                          @(_viewDistance),
                          @(_timeStep),
                          @(_clusterScale),
                          @(_velocityScale),
                          @(_softening),
                          @(_damping),
                          @(_pointSize),
                          @(_fullscreen),
                          @(_isGPUOnly),
                          @(_showUpdates),
                          @(_showFramerate),
                          @(_showCPU),
                          @(_showPerf),
                          @(_showDock)];
    
    return [[NSMutableDictionary alloc] initWithObjects:pObjects
                                                forKeys:pKeys];
} // _newPreferences

- (instancetype) init
{
    self = [super init];
    
    if(self)
    {
        NSMutableDictionary* pPrefsDst = [self _newPreferences];
        
        if(pPrefsDst)
        {
            _identifier = [[[NSBundle mainBundle] bundleIdentifier] retain];
            
            if(_identifier)
            {
                mpFile = [[NSFile alloc] initWithDomain:NSUserDomainMask
                                                 search:NSLibraryDirectory
                                              directory:@"Preferences"
                                                   file:_identifier
                                              extension:@"plist"];
                
                if(mpFile)
                {
                    NSMutableDictionary* pPrefsSrc = [[NSMutableDictionary alloc] initWithDictionary:mpFile.plist];
                    
                    if(pPrefsSrc)
                    {
                        [self _setPreferences:pPrefsSrc];
                        
                        [pPrefsDst addEntriesFromDictionary:pPrefsSrc];
                        
                        [pPrefsSrc release];
                    } // if
                } // if
            } // if
            
            mpPreferences = pPrefsDst;
            
            [mpFile replace:mpPreferences];
            
            [mpFile write];
        } // if
    } // if
    
    return self;
} // if

+ (instancetype) preferences
{
    return([[[NBodyPreferences allocWithZone:[self zone]] init] autorelease]);
} // preferences

- (void) dealloc
{
    if(mpFile)
    {
        [mpFile release];
        
        mpFile = nil;
    } // if
    
    if(_identifier)
    {
        [_identifier release];
        
        _identifier = nil;
    } // if
    
    if(mpPreferences)
    {
        [mpPreferences release];
        
        mpPreferences = nil;
    } // if
    
    [super dealloc];
} // dealloc

- (BOOL) addEntries:(NBodyPreferences *)preferences;
{
    BOOL success = NO;
    
    if(preferences)
    {
        NSDictionary* pPreferences = preferences.preferences;
        
        if(pPreferences)
        {
            success = [self _setPreferences:pPreferences];
            
            if(success)
            {
                [mpPreferences addEntriesFromDictionary:pPreferences];
                
                [mpFile replace:mpPreferences];
                
                [mpFile write];
            } // if
        } // if
    } // if
    
    return success;
} // update

- (NSDictionary *) preferences
{
    return mpPreferences;
} // if

- (BOOL) write
{
    [mpFile replace:mpPreferences];
    
    return [mpFile write];
} // write

- (void) setDemos:(int64_t)demos
{
    _demos = demos;
    
    mpPreferences[kNBodyPrefDemos] = @(_demos);
} // setConfigs

- (void) setBodies:(uint32_t)bodies
{
    _bodies = (bodies) ? bodies : NBody::Bodies::kCount;
    
    mpPreferences[kNBodyPrefBodies] = @(_bodies);
} // setBodies

- (void) setDemoType:(uint32_t)demoType
{
    _demoType = (demoType > 6) ? 1 : demoType;
    
    mpPreferences[kNBodyPrefDemoType] = @(_demoType);
} // setDemoType

- (void) setConfig:(uint32_t)config
{
    _config = config;
    
    mpPreferences[kNBodyPrefConfig] = @(_config);
} // setConfig

- (void) setMaxFramerate:(size_t)maxFramerate
{
    _maxFramerate = maxFramerate;
    
    mpPreferences[kNBodyPrefMaxFrameRate] = @(_maxFramerate);
} // setMaxFramerate

- (void) setMaxCPU:(size_t)maxCPU
{
    _maxCPU = maxCPU;
    
    mpPreferences[kNBodyPrefMaxCPU] = @(_maxCPU);
} // maxCPU

- (void) setMaxPerf:(size_t)maxPerf
{
    _maxPerf = maxPerf;
    
    mpPreferences[kNBodyPrefMaxPerf] = @(_maxPerf);
} // setMaxPerf

- (void) setMaxUpdates:(size_t)maxUpdates
{
    _maxUpdates = maxUpdates;
    
    mpPreferences[kNBodyPrefMaxUpdates] = @(_maxUpdates);
} // setMaxUpdates

- (void) setClearColor:(float)clearColor
{
    _clearColor = clearColor;
    
    mpPreferences[kNBodyPrefClearColor] = @(_clearColor);
} // setClearColor

- (void) setStarScale:(float)starScale
{
    _starScale = (starScale >= 0.125f) ? starScale : 1.0f;
    
    mpPreferences[kNBodyPrefStarScale] = @(_starScale);
} // setStarScale

- (void) setRotate:(NSPoint)rotate
{
    _rotate.x = rotate.x;
    _rotate.y = rotate.y;
    
    mpPreferences[kNBodyPrefRotateX] = @(_rotate.x);
    mpPreferences[kNBodyPrefRotateY] = @(_rotate.y);
} // setRotate

- (void) setSize:(NSSize)size
{
    _size.width  = (size.width  > 256.0f) ? size.width  : NBody::Window::kWidth;
    _size.height = (size.height > 256.0f) ? size.height : NBody::Window::kHeight;
    
    mpPreferences[kNBodyPrefSizeWidth]  = @(_size.width);
    mpPreferences[kNBodyPrefSizeHeight] = @(_size.height);
} // setSize

- (void) setViewDistance:(float)viewDistance
{
    _viewDistance = viewDistance;
    
    mpPreferences[kNBodyPrefViewDistance] = @(_viewDistance);
} // setViewDistance

- (void) setTimeStep:(float)timeStep
{
    _timeStep = timeStep;
    
    mpPreferences[kNBodyPrefTimeStep] = @(_timeStep);
} // setTimeStep

- (void) setClusterScale:(float)clusterScale
{
    _clusterScale = clusterScale;
    
    mpPreferences[kNBodyPrefClusterScale] = @(_clusterScale);
} // setClusterScale

- (void) setVelocityScale:(float)velocityScale
{
    _velocityScale = velocityScale;
    
    mpPreferences[kNBodyPrefVelocityScale] = @(_velocityScale);
} // setVelocityScale

- (void) setSoftening:(float)softening
{
    _softening = softening;
    
    mpPreferences[kNBodyPrefSoftening] = @(_softening);
} // setSoftening

- (void) setDamping:(float)damping
{
    _damping = damping;
    
    mpPreferences[kNBodyPrefDamping] = @(_damping);
} // setOscillation

- (void) setPointSize:(float)pointSize
{
    _pointSize = pointSize;
    
    mpPreferences[kNBodyPrefPointSize] = @(_pointSize);
} // setPointSize

- (void) setFullscreen:(BOOL)fullscreen
{
    _fullscreen = fullscreen;
    
    mpPreferences[kNBodyPrefFullScreen] = @(_fullscreen);
} // setFullscreen

- (void) setIsGPUOnly:(BOOL)isGPUOnly
{
    _isGPUOnly = isGPUOnly;
    
    mpPreferences[kNBodyPrefIsGPUOnly] = @(_isGPUOnly);
} // setIsGPUOnly

- (void) setShowUpdates:(BOOL)showUpdates
{
    _showUpdates = showUpdates;
    
    mpPreferences[kNBodyPrefShowUpdates] = @(_showUpdates);
} // setShowUpdates

- (void) setShowFramerate:(BOOL)showFramerate
{
    _showFramerate = showFramerate;
    
    mpPreferences[kNBodyPrefShowFrameRate] = @(_showFramerate);
} // setShowFramerate

- (void) setShowPerf:(BOOL)showPerf
{
    _showPerf = showPerf;
    
    mpPreferences[kNBodyPrefShowPerf] = @(_showPerf);
} // setShowPref

- (void) setShowDock:(BOOL)showDock
{
    _showDock = showDock;
    
    mpPreferences[kNBodyPrefShowDock] = @(_showDock);
} // setShowDock

- (void) setShowCPU:(BOOL)showCPU
{
    _showCPU = showCPU;
    
    mpPreferences[kNBodyPrefShowCPU] = @(_showCPU);
} // setShowCPU

@end
