const React = require('react')
const {Link} =  require('react-router')
const {Button, Input, Table} = require('react-bootstrap')
const $ = require('jquery')

const UsersTable = React.createClass({
  getGenderText: function(gender) {
    switch (gender) {
      case 1:
        return 'Male'
      case 2:
        return 'Female'
      default:
        return 'Unkown'
    }
  },

  render: function() {
    return (
      <Table striped bordered condensed hover>
        <thead>
          <tr>
            <th>id</th>
            <th>Username</th>
            <th>Nickname</th>
            <th>Gender</th>
          </tr>
        </thead>
        <tbody>
          {
            this.props.users.map(function(user) {
              return (
                <tr key={user.id}>
                  <td>{user.id}</td>
                  <td>
                    <Link to={`/users/${user.id}`}>
                      {user.username}
                    </Link>
                  </td>
                  <td>{user.nickname}</td>
                  <td>{this.getGenderText(user.gender)}</td>
                </tr>
                )
            }, this)
          }
        </tbody>
      </Table>
    )
  }
})

const USERS_URL = '/admin/users'

module.exports = React.createClass({
  loadUsersFromServer: function() {
    var searchValue = this.refs.search.getValue()
    var data
    if (searchValue) {
      data = {search: searchValue}
    }

    $.ajax({
      url: USERS_URL,
      dataType: 'json',
      cache: false,
      data: data,
      success: function(data) {
        this.setState({data: data})
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(USERS_URL, status, err.toString())
      }.bind(this)
    })
  },

  getInitialState: function() {
    return {data: []}
  },

  componentDidMount: function() {
    this.loadUsersFromServer()
  },

  render: function() {
    return (
      <div>
        <div className="input-group">
          <span className="input-group-btn">
            <Button onClick={this.loadUsersFromServer}>Search</Button>
          </span>
          <Input type="text" placeholder="Search by username or nickname" ref="search"/>
        </div>
        <div className="users-table-hint">Show at most 100 users. Use searching to show more.</div>
        <UsersTable users={this.state.data} />
      </div>
    )
  }
})
