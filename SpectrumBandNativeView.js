//  Created by react-native-create-bridge

import React, { Component } from 'react'
import { requireNativeComponent } from 'react-native'

const SpectrumBand = requireNativeComponent('SpectrumBand', SpectrumBandView)

export default class SpectrumBandView extends Component {
  render () {
    return <SpectrumBand {...this.props} />
  }
}

SpectrumBandView.propTypes = {
  exampleProp: React.PropTypes.string
}
