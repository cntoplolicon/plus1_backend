require('../css/app.css')
var React = require('react')
var ReactDom = require('react-dom')
var Desktop = require('./components/appDesktop')

ReactDom.render(
  <Desktop />,
  document.getElementById('content')
)