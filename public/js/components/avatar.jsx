const React = require('react')
const imageUrl = require('../imageUrl')

module.exports = React.createClass({
  render: function() {
    var avatar = this.props.avatar;
    if (!avatar) {
      return null;
    }
    return <img className="avatar" src={imageUrl(avatar)} />
  }
})
