/*
     File: OpenGLView.mm
 Abstract: 
 OpenGL view class with idle timer and fullscreen mode support.
 
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

#import <iostream>
#import <vector>

#import <OpenGL/gl.h>

#import "NBodyPreferences.h"
#import "NBodyConstants.h"
#import "NBodyEngine.h"

#import "GLcontainers.h"
#import "GLUQuery.h"

#import "OpenGLView.h"

#pragma mark -

static const NSOpenGLPixelFormatAttribute kOpenGLAttribsLegacyProfile[7] =
{
    NSOpenGLPFADoubleBuffer,
    NSOpenGLPFAAccelerated,
    NSOpenGLPFAAcceleratedCompute,
    NSOpenGLPFAAllowOfflineRenderers,   // NOTE: Needed to connect to compute-only gpus
    NSOpenGLPFADepthSize, 24,
    0
};

static const NSOpenGLPixelFormatAttribute kOpenGLAttribsLegacyDefault[4] =
{
    NSOpenGLPFADoubleBuffer,
    NSOpenGLPFADepthSize, 24,
    0
};

@implementation OpenGLView
{
    BOOL mbFullscreen;
    
    NSDictionary*    mpOptions;
    NSOpenGLContext* mpContext;
    NSTimer*         mpTimer;
    
    NBodyEngine*      mpEngine;
    NBodyPreferences* mpPrefs;

    IBOutlet NSPanel* mpHUD;
}

#pragma mark -
#pragma mark Private - Destructor

- (void) _cleanUpOptions
{
    if(mpOptions)
    {
        [mpOptions release];
        
        mpOptions = nil;
    } // if
} // _cleanUpOptions

- (void) _cleanUpTimer
{
    if(mpTimer)
    {
        [mpTimer invalidate];
        [mpTimer release];
    } // if
} // _cleanUpTimer

- (void) _cleanUpPrefs
{
    if(mpPrefs)
    {
        [mpPrefs addEntries:mpEngine.preferences];

        [mpPrefs write];
        [mpPrefs release];
        
        mpPrefs = nil;
    } // if
} // _cleanUpEngine

- (void) _cleanUpEngine
{
    if(mpEngine)
    {
        [mpEngine release];
        
        mpEngine = nil;
    } // if
} // _cleanUpEngine

- (void) _cleanUpObserver
{
    // If self isn't removed as an observer, the Notification Center
    // will continue sending notification objects to the deallocated
    // object.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
} // _cleanUpObserver

// Tear-down objects
- (void) _cleanup
{
    [self _cleanUpOptions];
    [self _cleanUpPrefs];
    [self _cleanUpTimer];
    [self _cleanUpEngine];
    [self _cleanUpObserver];
} // _cleanup

#pragma mark -
#pragma mark Private - Utilities - Misc.

// When application is terminating cleanup the objects
- (void) _quit:(NSNotification *)notification
{
    [self  _cleanup];
} // _quit

- (void) _idle
{
    [self setNeedsDisplay:YES];
} // _idle

- (void) _toggleFullscreen
{
    if(mpPrefs.fullscreen)
    {
        [self enterFullScreenMode:[NSScreen mainScreen]
                      withOptions:mpOptions];
    } // else
} // _toggleFullscreen

- (void) _alert:(NSString *)pMessage
{
    if(pMessage)
    {
        NSAlert* pAlert = [NSAlert new];
        
        if(pAlert)
        {
            [pAlert addButtonWithTitle:@"OK"];
            [pAlert setMessageText:pMessage];
            [pAlert setAlertStyle:NSCriticalAlertStyle];
            
            NSModalResponse response = [pAlert runModal];
            
            if(response == NSAlertFirstButtonReturn)
            {
                NSLog(@">> MESSAGE: %@", pMessage);
            } // if
            
            [pAlert release];
        } // if
    } // if
} // _alert

- (BOOL) _query
{
    GLU::Query query;
    
    // NOTE: For OpenCL 1.2 support refer to <http://support.apple.com/kb/HT5942>
    GLstrings keys =
    {
         "120",   "130",  "285",  "320M",
        "330M", "X1800", "2400",  "2600",
        "3000",  "4670", "4800",  "4870",
        "5600",  "8600", "8800", "9600M"
    };
    
    std::cout << ">> N-body Simulation: Renderer = \"" << query.renderer() << "\"" << std::endl;
    std::cout << ">> N-body Simulation: Vendor   = \"" << query.vendor()   << "\"" << std::endl;
    std::cout << ">> N-body Simulation: Version  = \"" << query.version()  << "\"" << std::endl;
    
    return BOOL(query.match(keys));
} // _query

- (NSOpenGLPixelFormat *) _newPixelFormat
{
    NSOpenGLPixelFormat* pFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:kOpenGLAttribsLegacyProfile];
    
    if(!pFormat)
    {
        NSLog(@">> WARNING: Failed to initialize an OpenGL context with the desired pixel format!");
        NSLog(@">> MESSAGE: Attempting to initialize with a fallback pixel format!");
        
        pFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:kOpenGLAttribsLegacyDefault];
    } // if
    
    return pFormat;
} // _newPixelFormat

#pragma mark -
#pragma mark Private - Utilities - Prepare

- (void) _preparePrefs
{
    mpPrefs = [NBodyPreferences new];
    
    if(mpPrefs)
    {
        mbFullscreen = mpPrefs.fullscreen;
    } // if
} // _preparePrefs

- (void) _prepareNBody
{
    if([self _query])
    {
        [self _alert:@"Requires OpenCL 1.2!"];
        
        [self _cleanUpOptions];
        [self _cleanUpTimer];
        
        exit(-1);
    } // if
    else
    {
        NSRect frame = [[NSScreen mainScreen] frame];
        
        mpEngine = [[NBodyEngine alloc] initWithPreferences:mpPrefs];
        
        if(mpEngine)
        {
            mpEngine.frame = frame;
            
            [mpEngine acquire];
        } // if
    } // else
} // _prepareNBody

- (void) _prepareRunLoop
{
    mpTimer = [[NSTimer timerWithTimeInterval:0.0
                                       target:self
                                     selector:@selector(_idle)
                                     userInfo:self
                                      repeats:true] retain];
    
    [[NSRunLoop currentRunLoop] addTimer:mpTimer
                                 forMode:NSRunLoopCommonModes];
} // _prepareRunLoop

#pragma mark -
#pragma mark Public - Designated Initializer

- (instancetype) initWithFrame:(NSRect)frameRect
{
    BOOL bIsValid = NO;
    
    NSOpenGLPixelFormat* pFormat = [self _newPixelFormat];
    
    if(pFormat)
    {
        self = [super initWithFrame:frameRect
                        pixelFormat:pFormat];
        
        if(self)
        {
            mpContext = [self openGLContext];
            bIsValid  = mpContext != nil;
            
            mpOptions = [[NSDictionary dictionaryWithObject:@(YES)
                                                     forKey:NSFullScreenModeSetting] retain];
            
            // It's important to clean up our rendering objects before we terminate -- Cocoa will
            // not specifically release everything on application termination, so we explicitly
            // call our cleanup (private object destructor) routines.
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(_quit:)
                                                         name:@"NSApplicationWillTerminateNotification"
                                                       object:NSApp];
        } // if
        else
        {
            NSLog(@">> ERROR: Failed to initialize an OpenGL context with attributes!");
        } // else
        
        [pFormat release];
    } // if
    else
    {
        NSLog(@">> ERROR: Failed to acquire a valid pixel format!");
    } // else
    
    if(!bIsValid)
    {
        exit(-1);
    } // if
    
    return self;
} // initWithFrame

#pragma mark -
#pragma mark Public - Destructor

- (void) dealloc
{
    [self _cleanup];
    
    [super dealloc];
} // dealloc

#pragma mark -
#pragma mark Public - Prepare

- (void) prepareOpenGL
{
    [super prepareOpenGL];
    
    [self _preparePrefs];
    [self _prepareNBody];
    [self _prepareRunLoop];
    
    [self _toggleFullscreen];
} // prepareOpenGL

#pragma mark -
#pragma mark Public - Delegates

- (BOOL) isOpaque
{
    return YES;
} // isOpaque

- (BOOL) acceptsFirstResponder
{
    return YES;
} // acceptsFirstResponder

- (BOOL) becomeFirstResponder
{
    return  YES;
} // becomeFirstResponder

- (BOOL) resignFirstResponder
{
    return YES;
} // resignFirstResponder

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
} // applicationShouldTerminateAfterLastWindowClosed

#pragma mark -
#pragma mark Public - Updates

- (void) renewGState
{
    [super renewGState];
    
    [[self window] disableScreenUpdatesUntilFlush];
} // renewGState

#pragma mark -
#pragma mark Public - Display

- (void) _resize
{
    if(mpEngine)
    {
        NSRect bounds = [self bounds];
        
        [mpEngine resize:bounds];
    } // if
} // _resize

- (void) reshape
{
    [self _resize];
} // reshape

- (void) drawRect:(NSRect)dirtyRect
{
    [mpEngine draw];
} // drawRect

#pragma mark -
#pragma mark Public - Help

- (IBAction) toggleHelp:(id)sender
{
    if([mpHUD isVisible])
    {
        [mpHUD orderOut:sender];
    } // if
    else
    {
        [mpHUD makeKeyAndOrderFront:sender];
    } // else
} // toggleHelp

#pragma mark -
#pragma mark Public - Fullscreen

- (IBAction) toggleFullscreen:(id)sender
{
    if([self isInFullScreenMode])
    {
        [self exitFullScreenModeWithOptions:mpOptions];
        
        [[self window] makeFirstResponder:self];
        
        mpPrefs.fullscreen = NO;
    } // if
    else
    {
        [self enterFullScreenMode:[NSScreen mainScreen]
                      withOptions:mpOptions];
        
        
        mpPrefs.fullscreen = YES;
    } // else
} // toggleFullscreen

#pragma mark -
#pragma mark Public - Keys

- (void) keyDown:(NSEvent *)event
{
    if(event)
    {
        NSString* pChars = [event characters];
        
        if([pChars length])
        {
            unichar key = [[event characters] characterAtIndex:0];
            
            if(key == 27)
            {
                [self toggleFullscreen:self];
            } // if
            else
            {
                mpEngine.command = key;
            } // else
        } // if
    } // if
} // keyDown

- (void) mouseDown:(NSEvent *)event
{
    if(event)
    {
        NSPoint where  = [event locationInWindow];
        NSRect  bounds = [self bounds];
        NSPoint point  = NSMakePoint(where.x, bounds.size.height - where.y);
        
        [mpEngine click:NBody::Mouse::Button::kDown
                  point:point];
    } // if
} // mouseDown

- (void) mouseUp:(NSEvent *)event
{
    if(event)
    {
        NSPoint where  = [event locationInWindow];
        NSRect  bounds = [self bounds];
        NSPoint point  = NSMakePoint(where.x, bounds.size.height - where.y);
        
        [mpEngine click:NBody::Mouse::Button::kUp
                  point:point];
    } // if
} // mouseUp

- (void) mouseDragged:(NSEvent *)event
{
    if(event)
    {
        NSPoint where = [event locationInWindow];
        
        where.y = 1080.0f - where.y;
        
        [mpEngine move:where];
    } // if
} // mouseDragged

- (void) scrollWheel:(NSEvent *)event
{
    if(event)
    {
        CGFloat dy = [event deltaY];
        
        [mpEngine scroll:dy];
    } // if
} // scrollWheel

@end
