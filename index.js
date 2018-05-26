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

class RNHighScores extends React.Component {
  state = {
    playing: false
  };
  componentDidMount() {}
  togglePlaying() {
    if (this.state.playing) {
      GStreamerBridge.pause();
    } else {
      GStreamerBridge.play();
    }
    this.setState({ playing: !this.state.playing });
  }
  render() {
    return (
      <View style={styles.container}>
        <DraggableCircle
          onPressIn={() => this.togglePlaying()}
          onMove={this.handleMove}
        />
      </View>
    );
  }
  handleMove({ moveY, moveX }) {
    GStreamerBridge.updateFreq(moveY, moveX / 300);
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "#4ABDAC"
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
