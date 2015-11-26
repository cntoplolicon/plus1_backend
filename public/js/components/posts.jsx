const React = require('react')
const $ = require('jquery')
const {ProgressBar, Grid, Row, Col, Button, Input, Panel} = require('react-bootstrap')
const {Link} = require('react-router')
const PostThumbnail = require('./postThumbnail')
const DatePicker = require('react-datepicker')
const moment = require('moment')

const PostsTable = React.createClass({
  render: function() {
    var posts = this.props.posts
    if (!posts) {
      var progress = this.state == null ? 0 : this.state.progress
      return <ProgressBar striped bsStyle="info" now={progress * 100} />
    }
    const POSTS_PER_ROW = 4
    var rows = []
    var k = 0
    for (var i = 0; i < posts.length / POSTS_PER_ROW; i++) {
      var cols = []
      var rowKey = ""
      for (var j = 0; j < POSTS_PER_ROW && k < posts.length; j++, k++) {
        var post = posts[k]
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
        rowKey += posts[k].id
      }
      rows.push(<Row key={rowKey}>{cols}</Row>)
    }
    return (
      <div>
        <Grid>{rows}</Grid>
      </div>
    )
  }
})

module.exports = React.createClass({
  loadPostsFromServer: function() {
    var url = '/admin/posts'
    var data = {
      recommended: this.state.recommended || undefined,
      date: this.state.startDate.format()
    }

    $.ajax({
      url: url,
      dataType: 'json',
      cache: false,
      data: data,
      success: function(data) {
        if (this.isMounted()) {
          this.setState({posts: data})
        }
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(url, status, err.toString())
      }.bind(this),
      xhr: function() {
        var xhr = new XMLHttpRequest()
        xhr.addEventListener("progress", function(event) {
          if (event.lengthComputable && this.isMounted()) {
            this.setState({progress: event.loaded / event.total})
          }
        }.bind(this), false)
        return xhr
      }.bind(this)
    })
  },

  getInitialState: function() {
    return {progress: 0, requesting: false, startDate: moment(), recommended: false}
  },

  componentDidMount: function() {
    this.loadPostsFromServer()
  },

  handleCheckBoxChange: function() {
    this.state.recommended = !this.state.recommended
    this.loadPostsFromServer()
  },

  handleDateChanged: function(date) {
    this.state.startDate = date
    this.loadPostsFromServer()
  },

  render: function() {
    return (
      <div>
        <DatePicker selected={this.state.startDate} onChange={this.handleDateChanged} />
        <Input onChange={this.handleCheckBoxChange} type="checkbox" label="Show recommended posts only" ref="checkbox" />
        <PostsTable posts={this.state.posts} />
      </div>
    )
  }
})
