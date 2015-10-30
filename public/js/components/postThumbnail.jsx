const React = require('react')
const {Thumbnail} = require('react-bootstrap')

module.exports = React.createClass({
  render: function() {
    var post = this.props.post
    var image = post.post_pages[0].image
    var srcProp = image ? {src: image} : {}
    return (
      <Thumbnail {...srcProp} onClick={this.props.onClick} className={post.recommendation !== null ? 'recommended' : ''} > 
        <p>{post.post_pages[0].text}</p>
      </Thumbnail>
    )
  }
})
