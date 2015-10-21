const React = require('react')
const PostThumbnail = require('./postThumbnail')
const {Row, Col, Grid, ProgressBar, ListGroup, ListGroupItem, Input, Button, Panel} = require('react-bootstrap')
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

  getCommentPlaceHolder: function() {
    var replyTo = this.state.replyTo
    if (replyTo) {
      return `Reply to ${replyTo.user.nickname}: ${replyTo.content}`
    }
    return 'Leave a comment'
  },

  setReplyTo: function(replyTo) {
    this.setState({replyTo: replyTo})
  },

  submitNewComment: function() {
    var username = this.refs.username.getValue()
    var password = this.refs.password.getValue()
    var content = this.refs.comment.getValue()
    var url = `/admin/posts/${this.props.params.postId}/comments`

    var replyToId = this.state.replyTo ? this.state.replyTo.id : undefined
    var data = {username: username, password: password, content: content, reply_to: replyToId}
    $.ajax({
      url: url,
      method: 'POST',
      dataType: 'json',
      data: data,
      success: function(data) {
        this.setState({post: data, comments: this.createCommentsTree(data)})
      }.bind(this),
      error: function(xhr, status, err) {
        if (xhr.status === 403) {
          alert("Username or password incorrect, or it's not an admin account")
        }
        console.error(url, status, err.toString())
      }.bind(this)
    })

  },

  submitRecommendation: function() {
    var recommendation = this.refs.recommendation.getValue()
    if (recommendation === '') {
      recommendation = null
    }
    var post = this.state.post
    post.recommendation = recommendation
    this.setState({post: post})
    var data = {recommendation: recommendation}
    var url = `/admin/posts/${this.props.params.postId}/recommendation`
    $.ajax({
      url: url,
      method: 'PUT',
      dataType: 'json',
      data: data,
      success: function(data) {
        this.setState({post: data, comments: this.createCommentsTree(data)})
      }.bind(this),
      error: function(xhr, status, err) {
        if (xhr.status === 403) {
          alert("Username or password incorrect, or it's not an admin account")
        }
        console.error(url, status, err.toString())
      }.bind(this)
    })
  },

  render: function() {
    var post = this.state.post
    if (!post) {
      return <ProgressBar striped bsStyle="info" now={this.state.progress * 100} />
    }

    const colWidth = 10
    const colOffset = Math.floor((12 - colWidth) / 2)
    if (this.state.replyTo) {
      var cancelReplyButton = <Button className="cancel-reply-button" onClick={this.setReplyTo.bind(this, undefined)}>Cancel Reply</Button>
    }
    return (
      <Grid>
        <Row>
          <Col xs={colWidth} xsOffset={colOffset}>
            <PostThumbnail post={post} />
          </Col>
        </Row>
        <Row>
          <Col xs={colWidth} xsOffset={colOffset}>
            <ListGroup>
              {
                this.state.comments.map(function(comment) {
                  var style = {paddingLeft: `${comment.level}em`}
                  return (
                    <ListGroupItem key={comment.id} onClick={this.setReplyTo.bind(this, comment)} >
                      <div style={style}>
                        <Link to={`/users/${comment.user.id}`}>
                          <span className="comment-user-nickname">{comment.user.nickname}</span>
                        </Link>
                        : <span>{comment.content}</span>
                      </div>
                    </ListGroupItem>
                    )
                }.bind(this))
              }
            </ListGroup>
          </Col>
        </Row>
        <Row>
          <Col xs={colWidth} xsOffset={colOffset}>
            <Panel defaultExpanded header="Recommendation">
              <form className="form-horizontal">
                <Input type="number" label="Recommendation" labelClassName="col-xs-3" wrapperClassName="col-xs-9"
                  ref="recommendation" onChange={this.submitRecommendation} value={this.state.post.recommendation} />
              </form>
            </Panel>
            <Panel defaultExpanded header="New Comment">
              <form className="form-horizontal">
                <Input type="text" label="Username" placeholder="Admin account username"
                  labelClassName="col-xs-3" wrapperClassName="col-xs-9" ref="username" />
                <Input type="password" label="Password" placeholder="Admin account password"
                  labelClassName="col-xs-3" wrapperClassName="col-xs-9" ref="password" />
                <Input type="textarea" label="Content" placeholder={this.getCommentPlaceHolder()}
                  labelClassName="col-xs-3" wrapperClassName="col-xs-9" ref="comment"/>
                <div className="form-group">
                  <Col xs={10} xsOffset={2}>
                    <Button bsStyle="primary" onClick={this.submitNewComment}>New Comment</Button>
                    {cancelReplyButton}
                  </Col>
                </div>
              </form>
            </Panel>
          </Col>
        </Row>
      </Grid>
    )
  }
})
