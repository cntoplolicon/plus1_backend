const React = require('react')

module.exports = React.createClass({
  render: function() {
    return (
      <div>
          <div className="page">
            <img className="block" width="100%" src="../images/mobile_background.png" />
            <a href="/plusone.apk">
              <img className="btn0" src="../images/mobile_android.png" />
            </a>
          </div>
      </div>
    )
  }

})