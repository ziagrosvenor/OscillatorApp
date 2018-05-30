#import <Foundation/Foundation.h>
#import "GStreamerBackendDelegate.h"

@interface GStreamerBackend : NSObject

/* Initialization method. Pass the delegate that will take care of the UI.
 * This delegate must implement the GStreamerBackendDelegate protocol */
-(id) init:(id) uiDelegate;

/* Set the pipeline to PLAYING */
-(void) play;

/* Set the pipeline to PAUSED */
-(void) pause;
-(void) updateFreq:(double)freq
              time:(double)time;
-(double) getVolume;
-(float) getFrequencyData:(int)idx;
-(void) setWaveform:(int)idx;

-(void) processMessage:(NSString*)messageType
               message:(NSString*)message;

+(GStreamerBackend *)sharedInstance;

@end
