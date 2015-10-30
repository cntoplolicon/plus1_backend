const React = require('react')

module.exports = React.createClass({
  render: function() {
    return (
      <div>
        <img className="center-block" src="../images/title.png" />
        <div className="background-yellow">
          <div className="image-container center-block">
            <img className="center-block" src="../images/introduction_main.png" />
            <a href="/plusone.apk" className="download">
              <img src="../images/download.png" />
            </a>
            <div className="qrcode" ref="qrcode">
            </div>
          </div>
        </div>
        <img className="center-block" src="../images/introduction_1.png" />
        <div className="background-grey">
          <img className="center-block" src="../images/introduction_2.png" />
        </div>
        <img className="center-block" src="../images/introduction_3.png" />
        <div className="background-grey">
          <img className="center-block" src="../images/introduction_4.png" />
        </div>
        <div className="foot">
          <p>©2015北京思无疆科技有限公司</p>
          <p> 京ICP备XXXXXXXX号</p>
        </div>
    </div>
    )
  },

  componentDidMount: function() {
    console.log('sdjfklsdjflsdfjl')
    console.log(this.refs.qrcode)
  }
})