//
//  main.m
//  OscillatorApp
//
//  Created by Zia on 25/05/2018.
//  Copyright © 2018 Zia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#include "gst_ios_init.h"

#import <AVFoundation/AVFoundation.h>

int main(int argc, char * argv[]) {
  @autoreleasepool {
    // Setup audio session
      AVAudioSession *session = [AVAudioSession sharedInstance];
      [session setCategory:AVAudioSessionCategoryPlayback error:nil];
      [session setActive:YES error:nil];
    
      gst_ios_init();
      return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
  }
}
