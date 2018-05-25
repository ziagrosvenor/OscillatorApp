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
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

/* Called when the Play button is pressed */
-(void) play:(id)sender
{
  [gst_backend play];
}

/* Called when the Pause button is pressed */
-(void) pause:(id)sender
{
  [gst_backend pause];
}

/*
 * Methods from GstreamerBackendDelegate
 */

-(void) gstreamerInitialized
{
  [gst_backend play];
  dispatch_async(dispatch_get_main_queue(), ^{
  
  });
}

-(void) gstreamerSetUIMessage:(NSString *)message
{
  dispatch_async(dispatch_get_main_queue(), ^{
    
  });
}

@end
