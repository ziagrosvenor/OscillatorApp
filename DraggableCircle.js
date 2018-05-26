import React, { Component } from "react";
import { StyleSheet, View, PanResponder, Animated } from "react-native";
import { throttle } from "lodash";
import styled from "styled-components/native";
let CIRCLE_RADIUS = 44;
const TouchPad = styled.TouchableOpacity`
  width: ${CIRCLE_RADIUS};
  height: ${CIRCLE_RADIUS};
  border-radius: ${CIRCLE_RADIUS};
`;

export default class Draggable extends Component {
  constructor() {
    super();
    this.state = {
      pan: new Animated.ValueXY()
    };
  }

  callOnMove(gestureState) {
    this.props.onMove(gestureState);
  }

  componentWillMount() {
    this.callOnMove = throttle(this.callOnMove, 5, { trailing: false });
    // Add a listener for the delta value change
    this._val = { x: 0, y: 0 };
    this.state.pan.addListener(value => {
      return (this._val = value);
    });
    // Initialize PanResponder with move handling
    this.panResponder = PanResponder.create({
      onStartShouldSetPanResponder: (e, gesture) => true,
      onPanResponderMove: (evt, gestureState) => {
        this.callOnMove({ ...gestureState });
        return Animated.event([
          null,
          { dx: this.state.pan.x, dy: this.state.pan.y }
        ])(evt, gestureState);
      }
    });
  }

  render() {
    const panStyle = {
      transform: this.state.pan.getTranslateTransform()
    };
    return (
      <Animated.View
        {...this.panResponder.panHandlers}
        style={[panStyle, styles.circle]}
      >
        <TouchPad
          onPressIn={this.props.onPressIn}
          onPressOut={this.props.onPressOut}
        />
      </Animated.View>
    );
  }
}

let styles = StyleSheet.create({
  circle: {
    backgroundColor: "#FC4A1A",
    width: CIRCLE_RADIUS * 2,
    height: CIRCLE_RADIUS * 2,
    borderRadius: CIRCLE_RADIUS
  }
});
