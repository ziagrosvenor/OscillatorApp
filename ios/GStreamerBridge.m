//  Created by react-native-create-bridge

#import "GStreamerBridge.h"

// import RCTBridge
#if __has_include(<React/RCTBridge.h>)
#import <React/RCTBridge.h>
#elif __has_include(“RCTBridge.h”)
#import “RCTBridge.h”
#else
#import “React/RCTBridge.h” // Required when used as a Pod in a Swift project
#endif

// import RCTEventDispatcher
#if __has_include(<React/RCTEventDispatcher.h>)
#import <React/RCTEventDispatcher.h>
#elif __has_include(“RCTEventDispatcher.h”)
#import “RCTEventDispatcher.h”
#else
#import “React/RCTEventDispatcher.h” // Required when used as a Pod in a Swift project
#endif

#include "GStreamerBackend.h"

@implementation GStreamerBridge {
  NSTimer *masterPositionTimer;
}

- (void)dealloc {
  if (masterPositionTimer != nil) {
    [masterPositionTimer invalidate];
    masterPositionTimer = nil;
  }
}

@synthesize bridge = _bridge;

// Export a native module
// https://facebook.github.io/react-native/docs/native-modules-ios.html
RCT_EXPORT_MODULE();


- (instancetype)init {
  if ((self = [super init])) {
    
  }
  return self;
}


// Export constants
// https://facebook.github.io/react-native/releases/next/docs/native-modules-ios.html#exporting-constants
- (NSDictionary *)constantsToExport
{
  return @{
           @"EXAMPLE": @"example"
         };
}

// Export methods to a native module
// https://facebook.github.io/react-native/docs/native-modules-ios.html
RCT_EXPORT_METHOD(hammerBridge)
{
  if (masterPositionTimer == nil) {
    dispatch_async(dispatch_get_main_queue(), ^{
      self->masterPositionTimer = [NSTimer scheduledTimerWithTimeInterval:.002
                                                                   target:self
                                                                 selector:@selector(onDisplayLink)
                                                                 userInfo:nil
                                                                  repeats:YES];
      [[NSRunLoop currentRunLoop] addTimer:self->masterPositionTimer forMode:NSRunLoopCommonModes];
    });
  } else {
    [masterPositionTimer invalidate];
    masterPositionTimer = nil;
  }
}

RCT_EXPORT_METHOD(pause)
{
  [[GStreamerBackend sharedInstance] pause];
}

RCT_EXPORT_METHOD(updateFreq:(nonnull NSNumber*)freq time:(nonnull NSNumber*)time)
{
  [[GStreamerBackend sharedInstance] updateFreq:[freq doubleValue] time:[time doubleValue]];
  
  
}

RCT_EXPORT_METHOD(setWaveform:(nonnull NSNumber*)idx)
{
  [[GStreamerBackend sharedInstance] setWaveform:[idx intValue]];
}

RCT_EXPORT_METHOD(sendMessage:(NSString*)messageType
                  message:(NSString*)message)
{
  [[GStreamerBackend sharedInstance] processMessage:messageType message:message];
}

// List all your events here
// https://facebook.github.io/react-native/releases/next/docs/native-modules-ios.html#sending-events-to-javascript
- (NSArray<NSString *> *)supportedEvents
{
  return @[@"EXAMPLE_EVENT"];
}

#pragma mark - Private methods

// Implement methods that you want to export to the native module
- (void) emitMessageToRN: (NSString *)eventName :(NSDictionary *)params {
  // The bridge eventDispatcher is used to send events from native to JS env
  // No documentation yet on DeviceEventEmitter: https://github.com/facebook/react-native/issues/2819
  [self sendEventWithName: eventName body: params];
}

// Called periodically on every screen refresh, 60 fps.
- (void)onDisplayLink {
  float       level;                // The linear 0.0 .. 1.0 value we need.
  const float minDecibels = -120.0f; // Or use -60dB, which I measured in a silent room.
  float       decibels    = [[GStreamerBackend sharedInstance] getFrequencyData:1] + 10.0;
  
  if (decibels < minDecibels)
  {
    level = 0.0f;
  }
  else if (decibels >= 0.0f)
  {
    level = 1.0f;
  }
  else
  {
    float   root            = 2.0f;
    float   minAmp          = powf(10.0f, 0.05f * minDecibels);
    float   inverseAmpRange = 1.0f / (1.0f - minAmp);
    float   amp             = powf(10.0f, 0.05f * decibels);
    float   adjAmp          = (amp - minAmp) * inverseAmpRange;
    
    level = powf(adjAmp, 1.0f / root);
  }
 
  [self sendEventWithName: @"EXAMPLE_EVENT" body:@{@"level": [NSNumber numberWithFloat:level], @"level2": [NSNumber numberWithFloat:level], @"level3": [NSNumber numberWithFloat:level]}];
}

@end
