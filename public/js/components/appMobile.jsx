const React = require('react')

const WeChatBackground = React.createClass({
  render: function() {
    if (!this.props.isShowing) {
      return null
    }
    return (
      <div className="wechat-background">
        <img className="wechat-prompt" src="../images/wechat_prompt.png" />
      </div>
    )
  }
})

module.exports = React.createClass({
  isWechat: function() {
    var ua = navigator.userAgent.toLowerCase()
    return /micromessenger/i.test(ua)
  },

  getInitialState: function() {
    return {isWechatPromptShowing: false}
  },

  handleDownload: function(e) {
    if (this.isWechat()) {
      e.preventDefault()
      this.setState({isWechatPromptShowing: true})
    }
  },

  render: function() {
    return (
      <div>
        <WeChatBackground isShowing={this.state.isWechatPromptShowing} />
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
