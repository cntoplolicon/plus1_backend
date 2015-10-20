const React = require('react')
const {Thumbnail} = require('react-bootstrap')
const imageUrl = require('../imageUrl')

module.exports = React.createClass({
  render: function() {
    var post = this.props.post
    var image = post.post_pages[0].image
    var srcProp = image ? {src: imageUrl(image)} : {}
    return (
      <Thumbnail {...srcProp}>
        <p>{post.post_pages[0].text}</p>
      </Thumbnail>
    )
  }
})
