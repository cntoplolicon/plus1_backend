const React = require('react')

const WeChatBackground = React.createClass({
  isWechat: function() {
    var ua = navigator.userAgent.toLowerCase();
    return /micromessenger/i.test(ua)
  },

  render: function() {
    if (!this.isWechat()) {
      return null;
    }
    return(
      <div>
        <img className="wechat-background" src="../images/wechat_background.png" />
      </div>
    )
  }
})

module.exports = React.createClass({
  render: function() {
    return (
      <div>
        <WeChatBackground/>
        <div className="page">
          <img className="block" width="100%" src="../images/mobile_background.png" />
          <a href="http://download.oneplusapp.com/plus-one.apk">
            <img className="btn0" src="../images/mobile_android.png" />
          </a>
        </div>
      </div>
    )
  }

})
