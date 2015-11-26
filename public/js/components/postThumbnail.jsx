const React = require('react')
const {Thumbnail} = require('react-bootstrap')
const moment = require('moment')

module.exports = React.createClass({
  formatDate: function(str) {
    return new moment(str).format('YYYY-MM-DD HH:mm:ss')
  },

  getPostClass: function() {
    var post = this.props.post
    if (post.deleted_by !== null) {
      return 'deleted'
    }
    return post.recommendation !== null ? 'recommended' : ''
  },

  render: function() {
    var post = this.props.post
    var image = post.post_pages[0].image
    var srcProp = image ? {src: image} : {}
    return (
      <Thumbnail {...srcProp} onClick={this.props.onClick} className={this.getPostClass()}>
        <p>{post.post_pages[0].text}</p>
        <p className="nickname">{post.user.nickname} {this.formatDate(post.created_at)}</p>
      </Thumbnail>
    )
  }
})
