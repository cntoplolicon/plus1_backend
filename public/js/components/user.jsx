const React = require('react')
const $ = require('jquery')
const {ProgressBar, Grid, Row, Col, Button, Input, Panel} = require('react-bootstrap')
const {Link} =  require('react-router')
const Avatar = require('./avatar')
const PostThumbnail = require('./postThumbnail')
const EventSelection = require('./eventSelection')

module.exports = React.createClass({
  loadUserFromServer: function() {
    var url = `/admin/users/${this.props.params.userId}`
    $.ajax({
      url: url,
      dataType: 'json',
      cache: false,
      success: function(data) {
        if (this.isMounted()) {
          this.setState({user: data})
        }
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(url, status, err.toString())
      }.bind(this),
      xhr: function() {
        var xhr = new XMLHttpRequest()
        xhr.addEventListener("progress", function(event) {
          if (event.lengthComputable) {
            this.setState({progress: event.loaded / event.total})
          }
        }.bind(this), false)
        return xhr
      }.bind(this)
    })
  },

  getInitialState: function() {
    return {progress: 0, requesting: false}
  },

  componentDidMount: function() {
    this.loadUserFromServer()
  },

  submitNewPost: function() {
    var data = new FormData()

    var text = this.refs.text.getValue()
    var image = this.refs.image.getInputDOMNode().files[0]
    if (!image && !text) {
      alert('Content cannot be blank')
      return
    }

    data.append('username', this.state.user.username)
    data.append('password', this.refs.password.getValue())
    if (text) {
      data.append('post_pages[][text]', text)
    }
    if (image) {
      data.append('post_pages[][image]', image)
    }

    var eventId = this.refs.event.getValue()
    if (eventId) {
      data.append('event_id', eventId)
    }

    this.setState({requesting: true})
    var url = `/admin/users/${this.props.params.userId}/posts`
    $.ajax({
      url: url,
      method: 'POST',
      dataType: 'json',
      processData: false,
      contentType: false,
      data: data,
      success: function(data) {
        if (this.isMounted()) {
          this.setState({user: data, requesting: false})
          this.refs.form.reset()
        }
      }.bind(this),
      error: function(xhr, status, err) {
        if (xhr.status === 403) {
          alert("Username or password incorrect, or it's not an admin account")
        }
        console.error(url, status, err.toString())
        this.setState({requesting: false})
      }.bind(this)
    })
  },

  render: function() {
    var user = this.state.user
    if (!user) {
      return <ProgressBar striped bsStyle="info" now={this.state.progress * 100} />
    }
    const POSTS_PER_ROW = 4
    var rows = []
    var k = 0
    for (var i = 0; i < user.posts.length / POSTS_PER_ROW; i++) {
      var cols = []
      var rowKey = ""
      for (var j = 0; j < POSTS_PER_ROW && k < user.posts.length; j++, k++) {
        var post = user.posts[k]
        cols.push(
          <Col key={post.id} xs={6} md={4} lg={3}>
            <Link to={`/posts/${post.id}`}>
              <PostThumbnail post={post} />
            </Link>
          </Col>
        )
        if (rowKey) {
          rowKey += '-'
        }
        rowKey += user.posts[k].id
      }
      rows.push(<Row key={rowKey}>{cols}</Row>)
    }
    return (
      <div>
        <div className="user-info-container">
          <div className="user-info-wrapper">
            <Avatar avatar={user.avatar} />
            <div>{user.username} {user.nickname}</div>
            <div>{user.biography}</div>
          </div>
        </div>
        <Grid>{rows}</Grid>
        <Panel defaultExpanded header="New Post">
          <form className="form-horizontal" ref="form">
            <Input type="password" label="Password" placeholder="Admin account password" labelClassName="col-xs-2" wrapperClassName="col-xs-10" ref="password" />
            <EventSelection label="Event" labelClassName="col-xs-2" wrapperClassName="col-xs-10" ref="event" />
            <Input type="file" label="Upload an image" labelClassName="col-xs-2" wrapperClassName="col-xs-10" ref="image" />
            <Input type="textarea" label="Say somehting" labelClassName="col-xs-2" wrapperClassName="col-xs-10" ref="text" />
            <div className="form-group">
              <Col xs={10} xsOffset={2}>
                <Button bsStyle="primary" onClick={this.submitNewPost} disabled={this.state.requesting}>New Post</Button>
              </Col>
            </div>
          </form>
        </Panel>
      </div>
    )
  }
})
