//  Created by react-native-create-bridge

import { NativeModules, NativeEventEmitter } from "react-native";

const { GStreamerBridge } = NativeModules;
const RNRippleAudioEmitter = new NativeEventEmitter(GStreamerBridge);

export default GStreamerBridge;
