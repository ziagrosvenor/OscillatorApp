//  Created by react-native-create-bridge

import { NativeModules } from 'react-native'

const { GStreamerBridge } = NativeModules

export default {
  exampleMethod () {
    return GStreamerBridge.exampleMethod()
  },

  EXAMPLE_CONSTANT: GStreamerBridge.EXAMPLE_CONSTANT
}
