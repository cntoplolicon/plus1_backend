const React = require('react')
const {Nav, Navbar, NavBrand, NavItem} = require('react-bootstrap')
const {LinkContainer} = require('react-router-bootstrap')

module.exports = React.createClass({
  render: function() {
    return (
      <div>
        <Navbar>
          <NavBrand>+1 Dashboard</NavBrand>
          <Nav>
            <LinkContainer to="/users">
              <NavItem>Users</NavItem>
            </LinkContainer>
            <LinkContainer to="/feedbacks">
              <NavItem>Feedbacks</NavItem>
            </LinkContainer>
            <LinkContainer to="/complains">
              <NavItem>Complains</NavItem>
            </LinkContainer>
            <LinkContainer to="/android_release">
              <NavItem>Android Release</NavItem>
            </LinkContainer>
          </Nav>
        </Navbar>
        <div className="container">
          {this.props.children}
        </div>
      </div>
    )
  }
})
