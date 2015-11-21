const React = require('react')
const {Button, Input, Table} = require('react-bootstrap')
const $ = require('jquery')
const moment = require('moment')
const {Link} =  require('react-router')

const ComplainsTable = React.createClass({
  formatDate: function(str) {
    return new moment(str).format('YYYY-MM-DD HH:mm:ss')
  },

  render: function() {
    return (
      <Table striped bordered condensed hover>
        <thead>
          <tr>
            <th>Report post id</th>
            <th>Report Username</th>
            <th>Report User Nickname</th>
            <th>Created at</th>
          </tr>
        </thead>
        <tbody>
          {
            this.props.complains.map(function(complain) {
              return (
                <tr key={complain.id}>
                  <td>
                    <Link to={`/posts/${complain.post_id}`}>
                     {complain.post_id}
                    </Link>
                  </td>
                  <td>{complain.user.username}</td>
                  <td>{complain.user.nickname}</td>
                  <td>{this.formatDate(complain.created_at)}</td>
                </tr>
              )
            }, this)
          }
        </tbody>
      </Table>
    )
  }
})

const COMPLAINS_URL = '/admin/complains'

module.exports = React.createClass({
  loadComplainsFromServer: function() {
    var username = this.refs.search.getValue()
    var data;
    if (username) {
      data = {username: username}
    }

    $.ajax({
      url: COMPLAINS_URL,
      dataType: 'json',
      cache: false,
      data: data,
      success: function(data) {
        if (this.isMounted()) {
          this.setState({data: data});
        }
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(USERS_URL, status, err.toString());
      }.bind(this)
    })
  },

  getInitialState: function() {
    return {data: []}
  },

  componentDidMount: function() {
    this.loadComplainsFromServer();
  },

  render: function() {
    return (
      <div>
        <div className="input-group">
          <span className="input-group-btn">
            <Button onClick={this.loadComplainsFromServer}>Search</Button>
          </span>
          <Input type="text" placeholder="Enter the full username to search for all of his/her complains" ref="search"/>
        </div>
        <div className="users-table-hint">Show the lastest 1000 complains in case of no searching</div>
        <ComplainsTable complains={this.state.data} />
      </div>
    )
  }
})
