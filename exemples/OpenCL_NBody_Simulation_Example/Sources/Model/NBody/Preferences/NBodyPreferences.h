/*
     File: NBodyPreferences.h
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

#import <Cocoa/Cocoa.h>

// Keys for the preferences dictionary     // For values
extern NSString* kNBodyPrefDemos;          // Signed integer 64
extern NSString* kNBodyPrefDemoType;       // Unsigned Integer 32
extern NSString* kNBodyPrefBodies;         // Unsigned Integer 32
extern NSString* kNBodyPrefConfig;         // Unsigned Integer 32
extern NSString* kNBodyPrefMaxUpdates;     // Unsigned Long
extern NSString* kNBodyPrefMaxFrameRate;   // Unsigned Long
extern NSString* kNBodyPrefMaxPerf;        // Unsigned Long
extern NSString* kNBodyPrefMaxCPU;         // Unsigned Long
extern NSString* kNBodyPrefRotateX;        // Double
extern NSString* kNBodyPrefRotateY;        // Double
extern NSString* kNBodyPrefSizeWidth;      // Double
extern NSString* kNBodyPrefSizeHeight;     // Double
extern NSString* kNBodyPrefClearColor;     // Float
extern NSString* kNBodyPrefStarScale;      // Float
extern NSString* kNBodyPrefViewDistance;   // Float
extern NSString* kNBodyPrefTimeStep;       // Float
extern NSString* kNBodyPrefClusterScale;   // Float
extern NSString* kNBodyPrefVelocityScale;  // Float
extern NSString* kNBodyPrefSoftening;      // Float
extern NSString* kNBodyPrefDamping;        // Float
extern NSString* kNBodyPrefPointSize;      // Float
extern NSString* kNBodyPrefFullScreen;     // BOOL
extern NSString* kNBodyPrefIsGPUOnly;      // BOOL
extern NSString* kNBodyPrefShowUpdates;    // BOOL
extern NSString* kNBodyPrefShowFrameRate;  // BOOL
extern NSString* kNBodyPrefShowPerf;       // BOOL
extern NSString* kNBodyPrefShowDock;       // BOOL
extern NSString* kNBodyPrefShowCPU;        // BOOL

@interface NBodyPreferences : NSObject

@property (nonatomic, readonly) NSString*     identifier;
@property (nonatomic, readonly) NSDictionary* preferences;

@property (nonatomic) int64_t demos;

@property (nonatomic) uint32_t demoType;
@property (nonatomic) uint32_t config;
@property (nonatomic) uint32_t bodies;

@property (nonatomic) size_t maxUpdates;
@property (nonatomic) size_t maxFramerate;
@property (nonatomic) size_t maxPerf;
@property (nonatomic) size_t maxCPU;

@property (nonatomic) NSPoint rotate;
@property (nonatomic) NSSize  size;

@property (nonatomic) float  timeStep;
@property (nonatomic) float  clusterScale;
@property (nonatomic) float  velocityScale;
@property (nonatomic) float  softening;
@property (nonatomic) float  damping;
@property (nonatomic) float  pointSize;
@property (nonatomic) float  starScale;
@property (nonatomic) float  viewDistance;
@property (nonatomic) float  clearColor;

@property (nonatomic) BOOL  isGPUOnly;
@property (nonatomic) BOOL  fullscreen;
@property (nonatomic) BOOL  showUpdates;
@property (nonatomic) BOOL  showFramerate;
@property (nonatomic) BOOL  showCPU;
@property (nonatomic) BOOL  showPerf;
@property (nonatomic) BOOL  showDock;

+ (instancetype) preferences;

- (BOOL) addEntries:(NBodyPreferences *)preferences;

- (BOOL) write;

@end
