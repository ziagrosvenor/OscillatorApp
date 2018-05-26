//
//  ViewController.m
//  OscillatorApp
//
//  Created by Zia on 25/05/2018.
//  Copyright © 2018 Zia. All rights reserved.
//

#import "ViewController.h"
#import "GStreamerBackend.h"

@interface ViewController ()

@end

@implementation ViewController {
  GStreamerBackend *gst_backend;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  gst_backend = [[GStreamerBackend alloc] init:self];
  NSURL *jsCodeLocation = [NSURL URLWithString:@"http://localhost:8081/index.bundle?platform=ios"];
  
  //NSURL *jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];

  RCTRootView *rootView =
  [[RCTRootView alloc] initWithBundleURL: jsCodeLocation
                              moduleName: @"OscillatorApp"
                       initialProperties: @{}
                           launchOptions: nil];
  
  self.view = rootView;

}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

/* Called when the Play button is pressed */
-(void) play
{
  [gst_backend play];
}

/* Called when the Pause button is pressed */
-(void) pause
{
  [gst_backend pause];
}

/*
 * Methods from GstreamerBackendDelegate
 */

-(void) gstreamerInitialized
{
  dispatch_async(dispatch_get_main_queue(), ^{
  
  });
}

-(void) gstreamerSetUIMessage:(NSString *)message
{
  dispatch_async(dispatch_get_main_queue(), ^{
    
  });
}

@end
