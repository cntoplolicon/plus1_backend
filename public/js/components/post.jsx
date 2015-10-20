const React = require('react')
const PostThumbnail = require('./postThumbnail')
const {Row, Col, Grid, ProgressBar, ListGroup, ListGroupItem} = require('react-bootstrap')
const {Link} =  require('react-router')
const $ = require('jquery')
const moment = require('moment')

module.exports = React.createClass({
  loadPostFromServer: function() {
    var url = `/admin/posts/${this.props.params.postId}`
    $.ajax({
      url: url,
      dataType: 'json',
      cache: false,
      success: function(data) {
        this.setState({post: data, comments: this.createCommentsTree(data)})
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
    return {progress: 0}
  },

  componentDidMount: function() {
    this.loadPostFromServer()
  },

  createCommentsTree: function(post) {
    var comments = post.comments.slice()
    comments.sort(function(c1, c2) {
      var m1 = moment(c1.created_at)
      var m2 = moment(c2.created_at)
      var timeDiff = m1 - m2
      if (timeDiff !== 0) {
        return timeDiff
      }
      return c1.id - c2.id
    })

    var id2comments = {}
    for (var comment of comments) {
      id2comments[comment.id] = comment
      comment.replies = []
    }
    for (var comment of comments) {
      comment.replyTo= id2comments[comment.reply_to_id]
      if (comment.replyTo) {
        comment.replyTo.replies.push(comment)
      }
    }
    var commentTree = []
    for (var comment of comments) {
      if (!comment.replyTo) {
        this.depthFirstSearch(comment, commentTree, 0)
      }
    }

    return commentTree
  },

  depthFirstSearch: function(comment, commentTree, level) {
    comment.level = level
    commentTree.push(comment)
    for (reply of comment.replies) {
      this.depthFirstSearch(reply, commentTree, level + 1)
    }
  },

  render: function() {
    var post = this.state.post
    if (!post) {
      return <ProgressBar striped bsStyle="info" now={this.state.progress * 100} />
    }
    
    return (
      <Grid>
        <Row>
          <Col xs={12} md={6}>
            <PostThumbnail post={post} />
          </Col>
          <Col xs={12} md={6}>
            <ListGroup>
              {
                this.state.comments.map(function(comment) {
                  var style = {paddingLeft: `${comment.level}em`}
                  return (
                    <ListGroupItem key={comment.id}>
                      <div style={style}>
                        <Link to={`/users/${comment.user.id}`}>
                          <span className="comment-user-nickname">{comment.user.nickname}</span>
                        </Link>
                        : <span>{comment.content}</span>
                      </div>
                    </ListGroupItem>
                    )
                })
              }
            </ListGroup>
          </Col>
        </Row>
      </Grid>
    )
  }
})
