import React from "react";
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  TouchableHighlight
} from "react-native";

import styled from "styled-components/native";

import GStreamerBridge from "./GStreamerBridgeNativeModule";
import DraggableCircle from "./DraggableCircle";

import { requireNativeComponent } from "react-native";

// requireNativeComponent automatically resolves 'RNTMap' to 'RNTMapManager'
const Band = requireNativeComponent("Band", null);

let CIRCLE_RADIUS = 88;
const TouchPad = styled.TouchableOpacity`
  width: ${CIRCLE_RADIUS};
  height: ${CIRCLE_RADIUS};
  border-radius: ${CIRCLE_RADIUS};
  background-color: white;
  justify-content: center;
  align-items: center;
  margin-top: 200px;
  margin-bottom: 100px;
`;
class RNHighScores extends React.Component {
  state = {
    playing: false
  };
  componentDidMount() {}
  togglePlaying = () => {
    if (this.state.playing) {
      GStreamerBridge.pause();
    } else {
      GStreamerBridge.play();
    }
    this.setState({ playing: !this.state.playing });
  };
  render() {
    const bands = [];
    for (let i = 0; i < 5; i++) {
      bands.push(
        <Band
          key={i}
          idx={i}
          style={{ color: "red", width: 400, height: 120 }}
        />
      );
    }

    return (
      <View style={styles.container}>
        <View style={{ top: 0, position: "absolute" }}>{bands}</View>
        <DraggableCircle
          onPressIn={() => this.togglePlaying()}
          onMove={this.handleMove}
        />
        <TouchPad onPress={this.togglePlaying}>
          <Text>{this.state.playing ? "PAUSE" : "PLAY"}</Text>
        </TouchPad>
      </View>
    );
  }
  handleMove({ moveY, moveX }) {
    GStreamerBridge.updateFreq(moveY / 800 * 200 + 30, moveX / 400 * 0.3 + 0.5);
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 200,
    flexDirection: "column-reverse",
    justifyContent: "center",
    alignItems: "center",
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
AppRegistry.registerComponent("OscillatorApp", () => RNHighScores);
