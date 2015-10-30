const React = require('react')

module.exports = React.createClass({
  render: function() {
    var avatar = this.props.avatar;
    if (!avatar) {
      return null;
    }
    return <img className="avatar" src={avatar} />
  }
})
