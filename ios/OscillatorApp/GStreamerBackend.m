//
//  GStreamerBackend.m
//  OscillatorApp
//
//  Created by Zia on 25/05/2018.
//  Copyright © 2018 Zia. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GStreamerBackend.h"

#include <GStreamer/gst/gst.h>

GST_DEBUG_CATEGORY_STATIC (debug_category);
#define GST_CAT_DEFAULT debug_category

@interface GStreamerBackend()
-(void)setUIMessage:(gchar*) message;
-(void)app_function;
-(void)check_initialization_complete;
@end

static guint spect_bands = 20;
float spectrumData[20];

@implementation GStreamerBackend {
  id ui_delegate;        /* Class that we use to interact with the user interface */
  GstElement *pipeline, *source, *source2, *add, *conv, *resample, *eq, *verb, *volume, *spectrum, *sink;
  GMainContext *context; /* GLib context used to run the main loop */
  GMainLoop *main_loop;  /* GLib main loop */
  gboolean initialized;  /* To avoid informing the UI multiple times about the initialization */
  
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
    
    GST_DEBUG_CATEGORY_INIT (debug_category, "tutorial-2", 0, "iOS tutorial 2");
    gst_debug_set_threshold_for_name("tutorial-2", GST_LEVEL_DEBUG);
    
    /* Start the bus monitoring task */
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [self app_function];
    });
  }
  
  return self;
}

-(void) dealloc
{
  if (pipeline) {
    GST_DEBUG("Setting the pipeline to NULL");
    gst_element_set_state(pipeline, GST_STATE_NULL);
    gst_object_unref(pipeline);
    pipeline = NULL;
  }
}

int waveCounter = 3;

-(void) play
{

  g_object_set(source, "wave", waveCounter, NULL);
  g_object_set(source2, "wave", waveCounter, NULL);
  
  
//  if (waveCounter >= 10) {
//    waveCounter = 0;
//  }
  gst_element_set_state(source2, GST_STATE_PLAYING);
  if(gst_element_set_state(pipeline, GST_STATE_PLAYING) == GST_STATE_CHANGE_FAILURE) {
    [self setUIMessage:"Failed to set pipeline to playing"];
  }
}

-(void) pause
{
  gst_element_set_state(source2, GST_STATE_PAUSED);
  if(gst_element_set_state(pipeline, GST_STATE_PAUSED) == GST_STATE_CHANGE_FAILURE) {
    [self setUIMessage:"Failed to set pipeline to paused"];
  }
}

- (float) getFrequencyData:(int)idx {
  return spectrumData[idx];
}

-(void) updateFreq:(double)freq
              time:(double)time
{
  g_object_set(source, "freq", freq, NULL);
  g_object_set(source2, "freq", freq * 4, NULL);
  g_object_set(verb, "room-size", time, NULL);
  g_object_set(verb, "level", time, NULL);
  
  g_object_set(eq, "band0", -(freq/ 400) * 24, NULL);
  g_object_set(eq, "band1", -(freq/ 400) * 24, NULL);
  g_object_set(eq, "band2", -(freq/ 400) * 24, NULL);

  g_object_set(volume, "volume", time * 6, NULL);
}



#define AUDIOFREQ 32000

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

/* Retrieve errors from the bus and show them on the UI */
static void error_cb (GstBus *bus, GstMessage *msg, GStreamerBackend *self)
{
  GError *err;
  gchar *debug_info;
  gchar *message_string;
  
  gst_message_parse_error (msg, &err, &debug_info);
  g_clear_error (&err);
  g_free (debug_info);
  [self setUIMessage:message_string];
  g_free (message_string);
  gst_element_set_state (self->pipeline, GST_STATE_NULL);
}

/* Notify UI about pipeline state changes */
static void state_changed_cb (GstBus *bus, GstMessage *msg, GStreamerBackend *self)
{
  GstState old_state, new_state, pending_state;
  gst_message_parse_state_changed (msg, &old_state, &new_state, &pending_state);
  /* Only pay attention to messages coming from the pipeline, not its children */
  if (GST_MESSAGE_SRC (msg) == GST_OBJECT (self->pipeline)) {
  
  }
}

/* Check if all conditions are met to report GStreamer as initialized.
 * These conditions will change depending on the application */
-(void) check_initialization_complete
{
  if (!initialized && main_loop) {
    if (ui_delegate && [ui_delegate respondsToSelector:@selector(gstreamerInitialized)])
    {
      [ui_delegate gstreamerInitialized];
    }
    initialized = TRUE;
  }
}

/* Main method for the bus monitoring code */
-(void) app_function
{
  GstBus *bus;
  GSource *bus_source;
  GError *error = NULL;
  
  GST_DEBUG ("Creating pipeline");
  
  /* Create our own GLib Main Context and make it the default one */
  context = g_main_context_new ();
  g_main_context_push_thread_default(context);
  /* Build pipeline */
  
  spectrum = gst_element_factory_make ("spectrum", "spectrum");
  g_object_set (G_OBJECT (spectrum), "bands", spect_bands, "threshold", -80,
                "post-messages", TRUE, "message-phase", TRUE, NULL);
  
  pipeline = gst_pipeline_new("sine");
  source   = gst_element_factory_make ("audiotestsrc",       "source");
  source2   = gst_element_factory_make ("audiotestsrc",       "source2");
  add   = gst_element_factory_make ("adder",       "add");
  conv     = gst_element_factory_make ("audioconvert",  "converter");
  resample     = gst_element_factory_make ("audioresample",  "resample");
  eq     = gst_element_factory_make ("equalizer-3bands",  "eq");
  verb     = gst_element_factory_make ("freeverb",  "verb");
  volume     = gst_element_factory_make ("volume",  "volume");
  sink     = gst_element_factory_make ("autoaudiosink", "audio-output");
  GstCaps *caps;
  
  gst_bin_add_many (GST_BIN (pipeline),
                    source, add, conv, resample, eq, verb, volume, spectrum, sink, NULL);
  
  
  /* Build pipeline */
  //pipeline = gst_parse_launch("audiotestsrc ! audioconvert ! audioresample ! autoaudiosink", &error);
  if (error) {
    gchar *message = g_strdup_printf("Unable to build pipeline: %s", error->message);
    g_clear_error (&error);
    [self setUIMessage:message];
    g_free (message);
    return;
  }
  
//  /gst_element_link_many (source, conv, resample, eq, verb, volume, spectrum, sink, NULL);
  
  caps = gst_caps_new_simple ("audio/x-raw",
                              "rate", G_TYPE_INT, AUDIOFREQ, NULL);
  
  if (!gst_element_link (source, add) ||
      !gst_element_link (add, conv) ||
      !gst_element_link (conv, resample) ||
      !gst_element_link (resample, eq) ||
      !gst_element_link (eq, verb) ||
      !gst_element_link (verb, volume) ||
      !gst_element_link_filtered (volume, spectrum, caps) ||
      !gst_element_link (spectrum, sink)) {
    fprintf (stderr, "can't link elements\n");
    exit (1);
  }
  gst_caps_unref (caps);
  
  
  gst_element_link (source2, add);
  
  
  /* Instruct the bus to emit signals for each received message, and connect to the interesting signals */
  bus = gst_element_get_bus (pipeline);
  bus_source = gst_bus_create_watch (bus);
  gst_bus_add_watch (bus, message_handler, NULL);
  g_source_set_callback (bus_source, (GSourceFunc) gst_bus_async_signal_func, NULL, NULL);
  g_source_attach (bus_source, context);
  g_source_unref (bus_source);
  g_signal_connect (G_OBJECT (bus), "message::error", (GCallback)error_cb, (__bridge void *)self);
  g_signal_connect (G_OBJECT (bus), "message::state-changed", (GCallback)state_changed_cb, (__bridge void *)self);
  gst_object_unref (bus);
  
  /* Create a GLib Main Loop and set it to run */
  GST_DEBUG ("Entering main loop...");
  main_loop = g_main_loop_new (context, FALSE);
  [self check_initialization_complete];
  g_main_loop_run (main_loop);
  GST_DEBUG ("Exited main loop");
  g_main_loop_unref (main_loop);
  main_loop = NULL;
  
  /* Free resources */
  g_main_context_pop_thread_default(context);
  g_main_context_unref (context);
  gst_element_set_state (pipeline, GST_STATE_NULL);
  gst_object_unref (pipeline);
  
  return;
}

@end
