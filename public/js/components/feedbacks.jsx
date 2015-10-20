const React = require('react')
const {Button, Input, Table} = require('react-bootstrap')
const $ = require('jquery')
const moment = require('moment')

const FeedbacksTable = React.createClass({
  formatDate: function(str) {
    return new moment(str).format('YYYY-MM-DD HH:mm:ss')
  },

  render: function() {
    return (
      <Table striped bordered condensed hover>
        <thead>
          <tr>
            <th>Username</th>
            <th>Nickname</th>
            <th>Contact</th>
            <th>Content</th>
            <th>Created at</th>
          </tr>
        </thead>
        <tbody>
          {
            this.props.feedbacks.map(function(feedback) {
              return (
                <tr key={feedback.id}>
                  <td>{feedback.user.username}</td>
                  <td>{feedback.user.nickname}</td>
                  <td>{feedback.contact}</td>
                  <td>{feedback.content}</td>
                  <td>{this.formatDate(feedback.created_at)}</td>
                </tr>
                )
            }, this)
          }
        </tbody>
      </Table>
    )
  }
})

const FEEDBACKS_URL = '/admin/feedbacks'

module.exports = React.createClass({
  loadFeedbacksFromServer: function() {
    var username = this.refs.search.getValue()
    var data;
    if (username) {
      data = {username: username}
    }

    $.ajax({
      url: FEEDBACKS_URL,
      dataType: 'json',
      cache: false,
      data: data,
      success: function(data) {
        this.setState({data: data});
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
    this.loadFeedbacksFromServer();
  },

  render: function() {
    return (
      <div>
        <div className="input-group">
          <span className="input-group-btn">
            <Button onClick={this.loadFeedbacksFromServer}>Search</Button>
          </span>
          <Input type="text" placeholder="Enter the full username to search for all of his/her feedbacks" ref="search"/>
        </div>
        <div className="users-table-hint">Show the lastest 1000 feedbakcs in case of no searching</div>
        <FeedbacksTable feedbacks={this.state.data} />
      </div>
    )
  }
})
