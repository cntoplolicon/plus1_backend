const React = require('react')
const $ = require('jquery')

module.exports = React.createClass({
  isWechat: function() {
    var ua = navigator.userAgent.toLowerCase()
    return /micromessenger/i.test(ua)
  },

  handleDownload: function(e) {
    if(this.isWechat()) {
      e.preventDefault()
      $('.wechat-background').show()
    }
  },

  render: function() {
    return (
      <div>
        <div className="wechat-background">
          <img className="wechat-prompt" src="../images/wechat_prompt.png" />
        </div>
        <div className="page">
          <img className="block" width="100%" src="../images/mobile_background.png" />
          <a onClick={this.handleDownload} href="http://download.oneplusapp.com/plus-one.apk">
            <img className="btn0" src="../images/mobile_android.png" />
          </a>
        </div>
      </div>
    )
  }
})
