const React = require('react')
const $ = require('jquery')
const {ProgressBar, Grid, Row, Col, Thumbnail} = require('react-bootstrap')
const Avatar = require('./avatar')
const imageUrl = require('../imageUrl')

const PostThumbnail = React.createClass({
  render: function() {
    var post = this.props.post;
    var image = post.post_pages[0].image
    var srcProp = image ? {src: imageUrl(image)} : {}
    return (
      <Thumbnail {...srcProp}>
        <p>{post.post_pages[0].text}</p>
      </Thumbnail>
    )
  }
})

module.exports = React.createClass({
  loadUserFromServer: function() {
    var url = `/admin/users/${this.props.params.userId}`
    $.ajax({
      url: url,
      dataType: 'json',
      cache: false,
      success: function(data) {
        this.setState({user: data});
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(url, status, err.toString());
      }.bind(this),
      xhr: function() {
        var xhr = new XMLHttpRequest();
        xhr.addEventListener("progress", function(event) {
          if (event.lengthComputable) {
            this.setState({progress: event.loaded / event.total});
          }
        }.bind(this), false);
        return xhr;
      }.bind(this)
    })
  },

  getInitialState: function() {
    return {progress: 0}
  },

  componentDidMount: function() {
    this.loadUserFromServer();
  },

  render: function() {
    var user = this.state.user;
    if (!user) {
      return <ProgressBar striped bsStyle="info" now={this.state.progress * 100} />
    }
    const POSTS_PER_ROW = 4;
    var rows = [];
    var k = 0;
    for (var i = 0; i < user.posts.length / POSTS_PER_ROW; i++) {
      var cols = [];
      var rowKey = "";
      for (var j = 0; j < POSTS_PER_ROW && k < user.posts.length; j++, k++) {
        cols.push(
          <Col key={user.posts[k].id} xs={6} md={4} lg={3}>
            <PostThumbnail post={user.posts[k]} />
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
      </div>
    )
  }
})
