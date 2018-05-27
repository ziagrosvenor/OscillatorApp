//
//  Band.m
//  OscillatorApp
//
//  Created by Zia on 26/05/2018.
//  Copyright © 2018 Zia. All rights reserved.
//

#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#include "Band.h"
#include "GStreamerBackend.h"

@implementation Band {
  CADisplayLink *displayLink;
}

- (void)dealloc {
}

- (instancetype)init {
  if ((self = [super init])) {
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onDisplayLink)];
    displayLink.frameInterval = 1;
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
   
  }
  return self;
}

// Called periodically on every screen refresh, 60 fps.
- (void)onDisplayLink {
  float       level;                // The linear 0.0 .. 1.0 value we need.
  const float minDecibels = -120.0f; // Or use -60dB, which I measured in a silent room.
  float       decibels    = [[GStreamerBackend sharedInstance] getFrequencyData:_idx] + 10.0;
  
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
  self.backgroundColor = [UIColor whiteColor];

  self.center = CGPointMake(((level * 2) * 350) - 200, (750 / 10) * _idx);
  
  self.alpha = level + 0.3;
}

@end
