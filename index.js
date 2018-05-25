import React from "react";
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  TouchableHighlight
} from "react-native";

import GStreamerBridge from "./GStreamerBridgeNativeModule";

class RNHighScores extends React.Component {
  componentDidMount() {}
  render() {
    return (
      <View style={styles.container}>
        <TouchableHighlight onPress={() => GStreamerBridge.exampleMethod()}>
          <Text style={styles.highScoresTitle}>Play</Text>
        </TouchableHighlight>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "#FFFFFF"
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
