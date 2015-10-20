const React = require('react')
const ReactDom = require('react-dom')
const {Router, Route, Link} = require('react-router')

const AppNav = require('./components/appNav')
const Users = require('./components/users')
const User = require('./components/user')
const Feedbacks = require('./components/feedbacks')

var Routes = (
  <Router>
    <Route path="/" component={AppNav}>
      <Route path="/users" component={Users} />
      <Route path="/users/:userId" component={User} />
      <Route path="/feedbacks" component={Feedbacks} />
    </Route>
  </Router>
)

ReactDom.render(Routes, document.getElementById('content'))
