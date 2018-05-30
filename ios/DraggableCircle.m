//
//  Band.m
//  OscillatorApp
//
//  Created by Zia on 26/05/2018.
//  Copyright © 2018 Zia. All rights reserved.
//

#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#include "DraggableCircle.h"
#include "GStreamerBackend.h"

@implementation DraggableCircle {
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


-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  [[GStreamerBackend sharedInstance] play];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  CGPoint position = [touch locationInView: self.superview];
  [[GStreamerBackend sharedInstance] updateFreq:position.y time:position.x / 400];
  
  [UIView animateWithDuration:.001
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^ {
                     
                     self.center = CGPointMake(position.x, position.y);
                   }
                   completion:^(BOOL finished) {}];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  [[GStreamerBackend sharedInstance] pause];
}

- (void)onDisplayLink {
  float       level;                // The linear 0.0 .. 1.0 value we need.
  const float minDecibels = -80.0f; // Or use -60dB, which I measured in a silent room.
  float       decibels    = [[GStreamerBackend sharedInstance] getFrequencyData:0];
  
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
  self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 8 * level, 8 * level);;
}
@end
