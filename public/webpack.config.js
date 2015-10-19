module.exports = {
  entry: './js/index.jsx',
  output: {
    filename: './dist/bundle.js'
  },
  module: {
    loaders: [
      {
        test: /\.jsx$/,
        loader: 'jsx-loader?insertPragma=React.DOM&harmony'
      }
    ]
  },
  resolve: {
    extensions: ['', '.js', '.jsx']
  },
  debug: true,
  devtool: 'eval-cheap-module-source-map'
}
