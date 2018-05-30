import React from "react";
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  TouchableHighlight,
  NativeEventEmitter
} from "react-native";

import styled from "styled-components/native";

import GStreamerBridge from "./GStreamerBridgeNativeModule";
import DraggableCircle from "./DraggableCircle";
import { requireNativeComponent } from "react-native";

const GStreamerBridgeEmitter = new NativeEventEmitter(GStreamerBridge);

// requireNativeComponent automatically resolves 'RNTMap' to 'RNTMapManager'
const Band = requireNativeComponent("Band", null);
const NativeDraggableCircle = requireNativeComponent("DraggableCircle", null);

let CIRCLE_RADIUS = 88;
const TouchPad = styled.TouchableOpacity`
  width: ${CIRCLE_RADIUS};
  height: ${CIRCLE_RADIUS};
  border-radius: ${CIRCLE_RADIUS};
  background-color: white;
  justify-content: center;
  align-items: center;
  margin-right: 20px;
`;

let W_CIRCLE_RADIUS = 88;
const Waveform = styled.TouchableOpacity`
  width: ${W_CIRCLE_RADIUS};
  height: ${W_CIRCLE_RADIUS};
  border-radius: ${W_CIRCLE_RADIUS};
  background-color: yellow;
  justify-content: center;
  align-items: center;
  margin: 4px;
`;

class OscillatorApp extends React.Component {
  state = {
    audioEngine: {
      isPlaying: false,
      waveform: 1,
      x: 200,
      y: 200
    },
    showWaveformMenu: false,
    level: 0.3
  };
  componentDidMount() {
    GStreamerBridge.sendMessage("INIT", JSON.stringify(this.state.audioEngine));
    GStreamerBridgeEmitter.addListener("EXAMPLE_EVENT", ({ level }) => {
      this.setState({ level: level });
    });
  }
  play = () => {
    const stateUpdate = { isPlaying: true };
    GStreamerBridge.sendMessage("PLAY", JSON.stringify(stateUpdate));
    this.setState({
      audioEngine: { ...this.state.audioEngine, ...stateUpdate }
    });
  };
  pause = () => {
    const stateUpdate = { isPlaying: false };
    GStreamerBridge.sendMessage("PAUSE", JSON.stringify(stateUpdate));
    this.setState({
      audioEngine: { ...this.state.audioEngine, ...stateUpdate }
    });
  };
  setWaveform = idx => {
    const stateUpdate = { waveform: idx };
    GStreamerBridge.sendMessage("SET_WAVEFORM", JSON.stringify(stateUpdate));
    this.setState({
      audioEngine: { ...this.state.audioEngine, ...stateUpdate }
    });
  };
  togglePlaying = () => {
    if (this.state.isPlaying) {
      GStreamerBridge.pause();
    } else {
      GStreamerBridge.play();
    }
    this.setState({ isPlaying: !this.state.isPlaying });
  };

  toggleWaveformMenu = () => {
    this.setState({ showWaveformMenu: !this.state.showWaveformMenu });
  };

  render() {
    const bands = [];
    const waveforms = [
      "SINE",
      "SQUARE",
      "SAW",
      "TRIANGLE",
      "SILENCE",
      "WHITE_N",
      "PINK_N",
      "SINE_TAB",
      "TICKS",
      "GAUSSIAN",
      "RED_N",
      "BLUE_N",
      "VIOLET_N"
    ];

    for (let i = 0; i < 20; i++) {
      bands.push(
        <Band
          key={i}
          idx={i}
          style={{ color: "red", width: 400, height: 640 / 10 }}
        />
      );
    }

    waveformComponents = waveforms.map((name, idx) => (
      <Waveform key={idx} onPress={() => this.setWaveform(idx)}>
        <Text style={{ fontSize: 12 }}>{name}</Text>
      </Waveform>
    ));

    const waveformText = this.state.showWaveformMenu
      ? "TOUCH"
      : waveforms[this.state.audioEngine.waveform];

    if (this.state.showWaveformMenu) {
      return (
        <View style={styles.waveformContainer}>
          <View style={{ top: 0, position: "absolute" }}>{bands}</View>
          {waveformComponents}
          <TouchPad onPress={this.toggleWaveformMenu}>
            <Text>{waveformText}</Text>
          </TouchPad>
          <TouchPad onPress={this.togglePlaying}>
            <Text>{this.state.isPlaying ? "STOP" : "HOLD"}</Text>
          </TouchPad>
        </View>
      );
    }

    return (
      <View style={styles.container}>
        <View style={{ top: 0, position: "absolute" }}>{bands}</View>
        <TouchPad onPress={this.toggleWaveformMenu}>
          <Text>{waveformText}</Text>
        </TouchPad>
        <DraggableCircle
          onPressIn={() => this.play()}
          onPressOut={() => this.pause()}
          onMove={this.handleMove}
        />
        <NativeDraggableCircle
          style={{
            backgroundColor: "black",
            opacity: 0.5,
            justifyContent: "center",
            alignItems: "center",
            width: CIRCLE_RADIUS,
            height: CIRCLE_RADIUS,
            borderRadius: CIRCLE_RADIUS / 2
          }}
        >
          <Text style={{ color: "white" }}>Native</Text>
        </NativeDraggableCircle>
      </View>
    );
  }
  handleMove({ moveY, moveX }) {
    GStreamerBridge.updateFreq(moveY, moveX / 400);
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 200,
    flexDirection: "row",
    justifyContent: "center",
    alignItems: "flex-end",
    backgroundColor: "orange"
  },

  waveformContainer: {
    flex: 1,
    padding: 40,
    flexDirection: "row",
    justifyContent: "flex-start",
    flexWrap: "wrap",
    alignItems: "flex-start",
    backgroundColor: "orange"
  },
  highScoresTitle: {
    fontSize: 20,
    textAlign: "center",
    margin: 10
  },
  scores: {
    textAlign: "center",
    color: "#333333",
    marginBottom: 5
  }
});

// Module name
AppRegistry.registerComponent("OscillatorApp", () => OscillatorApp);
