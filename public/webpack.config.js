var ExtractTextPlugin = require("extract-text-webpack-plugin")

module.exports = {
  entry: {
    admin: './js/admin.jsx',
    app: './js/app.js'
  },
  output: {
    path: './dist',
    filename: '[name].js'
  },
  module: {
    loaders: [
      {test: /\.jsx$/, loader: 'jsx-loader?insertPragma=React.DOM&harmony'},
      {test: /\.less$/, loader: 'style!css!less'},
      {test: /\.css$/, loader: ExtractTextPlugin.extract('style-loader', 'css-loader')},
      {test: /\.(woff|woff2)(\?v=\d+\.\d+\.\d+)?$/, loader: 'url?limit=10000&mimetype=application/font-woff'},
      {test: /\.ttf(\?v=\d+\.\d+\.\d+)?$/, loader: 'url?limit=10000&mimetype=application/octet-stream'},
      {test: /\.eot(\?v=\d+\.\d+\.\d+)?$/, loader: 'file'},
      {test: /\.svg(\?v=\d+\.\d+\.\d+)?$/, loader: 'url?limit=10000&mimetype=image/svg+xml'}
    ]
  },
  resolve: {
    extensions: ['', '.js', '.jsx']
  },
  debug: true,
  devtool: 'eval-cheap-module-source-map',

  plugins: [
    new ExtractTextPlugin("[name].css")
  ]
}
