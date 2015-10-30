const React = require('react')
const QRCode = require('qrcode-npm')

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
            <div className="qrcode" dangerouslySetInnerHTML={{__html: this.createQrcode()}} />
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

  createQrcode: function() {
    var qr = QRCode.qrcode(4, 'M');
    var downloadUrl = window.location.protocol + '//' + window.location.host + '/plusone.apk';
    qr.addData(downloadUrl);
    qr.make();
    return qr.createImgTag(5);
  }
})