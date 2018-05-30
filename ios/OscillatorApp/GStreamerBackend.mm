//
//  GStreamerBackend.m
//  OscillatorApp
//
//  Created by Zia on 25/05/2018.
//  Copyright © 2018 Zia. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <GStreamer/gst/gst.h>
#include "GStreamerBackend.h"
#include "Pipeline.mm"

#include "json.hpp"
// for convenience
using json = nlohmann::json;
using std::string;

GST_DEBUG_CATEGORY_STATIC (debug_category);
#define GST_CAT_DEFAULT debug_category

@interface GStreamerBackend()
-(void)setUIMessage:(gchar*) message;
-(void)app_function;
-(void)check_initialization_complete;
@end

float spectrumData[20];

@implementation GStreamerBackend {
  id ui_delegate;        /* Class that we use to interact with the user interface */
  Pipeline *pipeline;
}

/*
 * Interface methods
 */

static GStreamerBackend *_sharedGStreamerBackend = nil;

+(GStreamerBackend *)sharedInstance {
  @synchronized([GStreamerBackend class]) {
    if (!_sharedGStreamerBackend)
      _sharedGStreamerBackend = [[self alloc] init];
    return _sharedGStreamerBackend;
  }
  return nil;
}

-(id) init:(id) uiDelegate
{
  if (! _sharedGStreamerBackend)
  {
    _sharedGStreamerBackend = [super init];
    self->ui_delegate = uiDelegate;
    pipeline = new Pipeline();
    
    GST_DEBUG_CATEGORY_INIT (debug_category, "tutorial-2", 0, "iOS tutorial 2");
    gst_debug_set_threshold_for_name("tutorial-2", GST_LEVEL_DEBUG);
    
    /* Start the bus monitoring task */
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      self->pipeline->appFunction();
    });
  }
  
  return self;
}

-(void) dealloc
{
  delete pipeline;
}

int waveCounter = 2;

-(void) play
{
  pipeline->play();
}

-(void) pause
{
  pipeline->pause();

}

- (float) getFrequencyData:(int)idx {
  return pipeline->getFrequencyData(idx);
}

-(void) updateFreq:(double)freq
              time:(double)time
{
  pipeline->updateCoordinates(time, freq);
}

-(void) setWaveform:(int)idx {
  pipeline->setWaveform(idx);
};

#define AUDIOFREQ 44000
/* receive spectral data from element message */
static gboolean
message_handler (GstBus * bus, GstMessage * message, gpointer data)
{
  if (message->type == GST_MESSAGE_ELEMENT) {
    const GstStructure *s = gst_message_get_structure (message);
    const gchar *name = gst_structure_get_name (s);
    GstClockTime endtime;
    
    if (strcmp (name, "spectrum") == 0) {
      const GValue *magnitudes;
      const GValue *phases;
      const GValue *mag, *phase;
      gdouble freq;
      guint i;
      
      if (!gst_structure_get_clock_time (s, "endtime", &endtime))
        endtime = GST_CLOCK_TIME_NONE;
      
      magnitudes = gst_structure_get_value (s, "magnitude");
      phases = gst_structure_get_value (s, "phase");
      
      for (i = 0; i < spect_bands; ++i) {
        freq = (gdouble) ((AUDIOFREQ / 2) * i + AUDIOFREQ / 4) / spect_bands;
        mag = gst_value_list_get_value (magnitudes, i);
        phase = gst_value_list_get_value (phases, i);

        
        if (mag != NULL && phase != NULL) {
          spectrumData[i] = g_value_get_float (mag);
        }
      }

    }
  }
  return TRUE;
}

/*
 * Private methods
 */

/* Change the message on the UI through the UI delegate */
-(void)setUIMessage:(gchar*) message
{
  NSString *string = [NSString stringWithUTF8String:message];
  if(ui_delegate && [ui_delegate respondsToSelector:@selector(gstreamerSetUIMessage:)])
  {
    [ui_delegate gstreamerSetUIMessage:string];
  }
}

/* Check if all conditions are met to report GStreamer as initialized.
 * These conditions will change depending on the application */
-(void) check_initialization_complete
{
 
}

-(void) processMessage:(NSString*)_messageType
           message:(NSString*)_messageJson {
  string messageType([_messageType UTF8String]);
  string messageJson([_messageJson UTF8String]);
  pipeline->processMessage(messageType, messageJson);
}

/* Main method for the bus monitoring code */
-(void) app_function
{
  
}

@end
