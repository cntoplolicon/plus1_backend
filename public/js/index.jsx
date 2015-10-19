const React = require('react')
const ReactDom = require('react-dom')
const $ = require('jquery')
const {Nav, Navbar, NavBrand, NavItem} = require('react-bootstrap')
const {Router, Route, Link} = require('react-router')
const {LinkContainer} = require('react-router-bootstrap')

var Nav1 = React.createClass({
  render: function() {
    return (
      <Navbar>
        <NavBrand>React-Bootstrap</NavBrand>
        <Nav>
          <NavItem eventKey={1} href="#">Link</NavItem>
          <LinkContainer to="/posts/3">
            <NavItem eventKey={2}>Link</NavItem>
          </LinkContainer>
        </Nav>
      </Navbar>
    )
  }
})

var Nav2 = React.createClass({
  render: function() {
    return (
      <Navbar>
        <NavBrand>React-Bootstrap2</NavBrand>
        <Nav>
          <NavItem eventKey={1} href="#">Link</NavItem>
          <NavItem eventKey={2} href="#">Link</NavItem>
        </Nav>
      </Navbar>
    )
  }
})

var AppRoute = React.createClass({
  render: function() {
    return (
      <Router>
        <Route path="/" component={Nav1}>
        </Route>
        <Route path="/posts/:post_id" component={Nav2} />
      </Router>
    )
  }
})

ReactDom.render(<AppRoute />, document.getElementById('content'))
