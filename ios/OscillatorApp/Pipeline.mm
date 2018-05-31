#import <Foundation/Foundation.h>
#include <GStreamer/gst/gst.h>

#include "json.hpp"
#define AUDIOFREQ 44000

using json = nlohmann::json;
using std::string;
using std::map;
static guint spect_bands = 20;

static map<string, int> WaveformsIdxMap {
  {string("SINE"), 0},
  {string("SQUARE"), 1},
  {string("SAW"), 2},
};

class Pipeline {
  GstElement *pipeline, *source, *source2, *add, *conv, *resample, *eq, *verb, *volume, *spectrum, *sink;
  GMainContext *context; /* GLib context used to run the main loop */
  GMainLoop *main_loop;  /* GLib main loop */
  gboolean initialized;  /* To avoid informing the UI multiple times about the initialization */
  json audioEngineStateJson;
public:
  Pipeline() {
    
  };
  ~Pipeline() {
    if (pipeline) {
      GST_DEBUG("Setting the pipeline to NULL");
      gst_element_set_state(pipeline, GST_STATE_NULL);
      gst_object_unref(pipeline);
      pipeline = NULL;
    }
  };
  
  inline void init() {
    gst_debug_set_threshold_for_name("tutorial-2", GST_LEVEL_DEBUG);
  };
  
  inline void play() {
    if(gst_element_set_state(pipeline, GST_STATE_PLAYING) == GST_STATE_CHANGE_FAILURE) {
    }
  };
  
  inline void pause() {
    if(gst_element_set_state(pipeline, GST_STATE_PAUSED) == GST_STATE_CHANGE_FAILURE) {
    
    }
  };
  inline float getFrequencyData(int idx) {
    return spectrumData[idx];
  }
  
  inline void updateCoordinates(double x, double y) {
    g_object_set(source, "freq", y, NULL);
    g_object_set(verb, "room-size", x, NULL);
    g_object_set(verb, "level", x, NULL);
    g_object_set(eq, "band0", -x * 12, NULL);
    g_object_set(eq, "band2", -(y / 800) * 24, NULL);
    g_object_set(volume, "volume", x, NULL);
  }
  
  inline void setWaveform(int idx) {
    g_object_set(source, "wave", idx, NULL);
  }

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
            ((Pipeline *)data)->spectrumData[i] = g_value_get_float (mag);
          }
        }
        
      }
    }
    return TRUE;
  }

  /* Retrieve errors from the bus and show them on the UI */
  static void error_cb (GstBus *bus, GstMessage *msg, Pipeline *_this)
  {
    GError *err;
    gchar *debug_info;
    gchar *message_string = nullptr;
    
    gst_message_parse_error (msg, &err, &debug_info);
    g_clear_error (&err);
    g_free (debug_info);
    g_free (message_string);
    gst_element_set_state (_this->pipeline, GST_STATE_NULL);
  }
  
  static void state_changed_cb (GstBus *bus, GstMessage *msg, Pipeline *_this)
  {
    GstState old_state, new_state, pending_state;
    gst_message_parse_state_changed (msg, &old_state, &new_state, &pending_state);
    /* Only pay attention to messages coming from the pipeline, not its children */
    if (GST_MESSAGE_SRC (msg) == GST_OBJECT (_this->pipeline)) {
      
    }
  }
  
  /* Check if all conditions are met to report GStreamer as initialized.
   * These conditions will change depending on the application */
  void check_initialization_complete()
  {
    if (!initialized && main_loop) {
      initialized = TRUE;
    }
  }
  
  void processMessage(string messageType, string messageJson) {
    if (messageType == "INIT") {
      audioEngineStateJson = json::parse(messageJson);
      g_object_set(source, "wave", audioEngineStateJson["waveform"].get<int>(), NULL);
      return;
    }
    
    json message = json::parse(messageJson);
    audioEngineStateJson.merge_patch(message);
    
    int waveform = audioEngineStateJson["waveform"].get<int>();
    int x = audioEngineStateJson["x"].get<int>();
    int y = audioEngineStateJson["y"].get<int>();
    
    if (messageType == "PLAY") {
      play();
    } else if (messageType == "PAUSE") {
      //[self pause]
      pause();
    } else if (messageType == "SET_WAVEFORM") {
      g_object_set(source, "wave", waveform, NULL);
    } else if (messageType == "UPDATE_OSC") {
      g_object_set(source, "freq", (double)y, NULL);
      g_object_set(verb, "room-size", (double)x, NULL);
      g_object_set(verb, "level", (double)x, NULL);
      g_object_set(eq, "band0", -(double)x * 12, NULL);
      g_object_set(eq, "band2", -(y / 800) * 24, NULL);
      g_object_set(volume, "volume", x, NULL);
    }
  }
  
  inline void appFunction() {
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
                      source, source2, add, conv, resample, eq, verb, volume, spectrum, sink, NULL);
    
    /* Build pipeline */
    if (error) {
      gchar *message = g_strdup_printf("Unable to build pipeline: %s", error->message);
      g_clear_error (&error);
      g_free (message);
      return;
    }
    
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
    
    /* Instruct the bus to emit signals for each received message, and connect to the interesting signals */
    bus = gst_element_get_bus (pipeline);
    bus_source = gst_bus_create_watch (bus);
    gst_bus_add_watch (bus, message_handler, (void *)this);
    g_source_set_callback (bus_source, (GSourceFunc) gst_bus_async_signal_func, NULL, NULL);
    g_source_attach (bus_source, context);
    g_source_unref (bus_source);
    g_signal_connect (G_OBJECT (bus), "message::error", (GCallback)error_cb, (void *)this);
    g_signal_connect (G_OBJECT (bus), "message::state-changed", (GCallback)state_changed_cb, (void *)this);
    gst_object_unref (bus);
    
    /* Create a GLib Main Loop and set it to run */
    GST_DEBUG ("Entering main loop...");
    main_loop = g_main_loop_new (context, FALSE);
    g_main_loop_run (main_loop);
    GST_DEBUG ("Exited main loop");
    g_main_loop_unref (main_loop);
    main_loop = NULL;
    
    /* Free resources */
    g_main_context_pop_thread_default(context);
    g_main_context_unref (context);
    gst_element_set_state (pipeline, GST_STATE_NULL);
    gst_object_unref (pipeline);
    
  }
  float spectrumData[20];
private:
  
};

