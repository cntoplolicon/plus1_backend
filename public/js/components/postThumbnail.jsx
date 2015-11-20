const React = require('react')
const {Thumbnail} = require('react-bootstrap')

module.exports = React.createClass({
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
      </Thumbnail>
    )
  }
})
