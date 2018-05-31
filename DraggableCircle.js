import React, { Component } from "react";
import {
  StyleSheet,
  View,
  TouchableOpacity,
  Text,
  PanResponder,
  Animated
} from "react-native";
import { throttle } from "lodash";
import styled from "styled-components/native";
let CIRCLE_RADIUS = 66;
const TouchPad = styled.TouchableOpacity`
  width: ${CIRCLE_RADIUS};
  height: ${CIRCLE_RADIUS};
  border-radius: ${CIRCLE_RADIUS};
`;

export default class Draggable extends Component {
  constructor() {
    super();
    this.state = {
      x: 0,
      y: 0
    };
  }

  callOnMove(gestureState) {
    this.props.onMove(gestureState);
  }

  componentWillMount() {
    this.callOnMove = throttle(this.callOnMove, 5, { trailing: false });
    // Add a listener for the delta value change
    this._val = { x: 0, y: 0 };

    // Initialize PanResponder with move handling
    this.panResponder = PanResponder.create({
      onStartShouldSetPanResponder: (e, gesture) => true,
      onPanResponderGrant: () => {
        this.props.onPressIn();
      },
      onPanResponderMove: (evt, gestureState) => {
        this.setState({
          x: gestureState.moveX,
          y: gestureState.moveY
        });
        this.callOnMove({ ...gestureState });
      },
      onPanResponderRelease: () => {
        this.props.onPressOut();
      }
    });
  }

  render() {
    return (
      <Animated.View
        {...this.panResponder.panHandlers}
        style={{
          left: this.state.x - CIRCLE_RADIUS,
          top: this.state.y - CIRCLE_RADIUS,
          backgroundColor: "black",
          opacity: this.props.scale,
          position: "absolute",
          justifyContent: "center",
          alignItems: "center",
          width: CIRCLE_RADIUS * 2,
          height: CIRCLE_RADIUS * 2,
          borderRadius: CIRCLE_RADIUS
        }}
      >
        <Text style={{ color: "white" }}>JS</Text>
      </Animated.View>
    );
  }
}

let styles = StyleSheet.create({
  circle: {
    backgroundColor: "black",
    opacity: 0.5,
    width: CIRCLE_RADIUS * 2,
    height: CIRCLE_RADIUS * 2,
    borderRadius: CIRCLE_RADIUS
  }
});
