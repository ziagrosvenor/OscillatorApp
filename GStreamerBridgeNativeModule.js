//  Created by react-native-create-bridge

import { NativeModules, NativeEventEmitter } from "react-native";

const { GStreamerBridge } = NativeModules;

export const GStreamerBridgeEmitter = new NativeEventEmitter(GStreamerBridge);

export default GStreamerBridge;
