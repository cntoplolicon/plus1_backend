var assign = require('object-assign')
var webpack = require('webpack')
var defaultOptions = require('./webpack.config.js')

module.exports = assign(defaultOptions, {
  debug: false,
  devtool: undefined,
  plugins: defaultOptions.plugins.concat([
    new webpack.optimize.UglifyJsPlugin({minimize: true}),
    new webpack.DefinePlugin({'process.env': {'NODE_ENV': JSON.stringify('production')}})
  ])
})
