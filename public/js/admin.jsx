require('../css/admin.css')
require('bootstrap/less/bootstrap.less')

const React = require('react')
const ReactDom = require('react-dom')
const {Router, Route} = require('react-router')

const AppNav = require('./components/appNav')
const Users = require('./components/users')
const User = require('./components/user')
const Post = require('./components/post')
const Feedbacks = require('./components/feedbacks')
const AndroidRelease = require('./components/androidRelease.jsx')

var Routes = (
  <Router>
    <Route path="/" component={AppNav}>
      <Route path="/users" component={Users} />
      <Route path="/users/:userId" component={User} />
      <Route path="/posts/:postId" component={Post} />
      <Route path="/feedbacks" component={Feedbacks} />
      <Route path="/android_release" component={AndroidRelease} />
    </Route>
  </Router>
)

ReactDom.render(Routes, document.getElementById('content'))
