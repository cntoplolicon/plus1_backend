const React = require('react')
const ReactDom = require('react-dom')
const {Router, Route, Link} = require('react-router')

const AppNav = require('./components/appNav')
const Users = require('./components/users')

var Routes = (
  <Router>
    <Route path="/" component={AppNav}>
      <Route path="/users" component={Users} />
    </Route>
  </Router>
)

ReactDom.render(Routes, document.getElementById('content'))
