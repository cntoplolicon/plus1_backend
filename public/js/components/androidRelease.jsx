const React = require('react')
const {FormControls, Col, Input, Panel, Button} = require('react-bootstrap')
const $ = require('jquery')
const assign = require('object-assign')

module.exports = React.createClass({
  getInitialState: function() {
    return {release: {}, editing: false}
  },

  componentDidMount: function() {
    this.loadReleaseFromServer()
  },

  loadReleaseFromServer: function() {
    var url = '/admin/app_release/android'
    $.ajax({
      url: url,
      dataType: 'json',
      cache: false,
      success: function(data) {
        if (this.isMounted()) {
          this.setState({release: data, editing: false})
        }
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(url, status, err.toString())
      }.bind(this)
    })
  },

  edit: function() {
    this.setState({editing: true})
  },

  submitNewRelease: function() {
    var url = '/admin/app_release/android'

    var data = new FormData()
    var message = this.refs.message.getValue()
    var archive = this.refs.archive.getInputDOMNode().files[0]
    data.append('message', message)
    if (archive) {
      data.append('archive', archive)
    }
    $.ajax({
      url: url,
      method: 'POST',
      dataType: 'json',
      processData: false,
      contentType: false,
      data: data,
      success: function(data) {
        if (this.isMounted()) {
          this.setState({release: data, editing: false})
        }
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(url, status, err.toString())
      }.bind(this)
    })
  },

  changeMessage: function() {
    this.setState({release: assign(this.state.release, {message: event.target.value})})
  },

  render: function() {
    return (
      <Panel defaultExpanded header="Android Release">
        <form className="form-horizontal">
          <FormControls.Static type="file" label="Version Code"
            labelClassName="col-xs-2" wrapperClassName="col-xs-10" value={this.state.release.version_code} />
          <Input type="file" disabled={!this.state.editing} label="Upload the archive"
            labelClassName="col-xs-2" wrapperClassName="col-xs-10" ref="archive" />
          <Input type="textarea" disabled={!this.state.editing} label="Message" onChange={this.changeMessage}
            labelClassName="col-xs-2" wrapperClassName="col-xs-10" ref="message" value={this.state.release.message} />
          <div className="form-group">
            <Col xs={10} xsOffset={2}>
              <Button bsStyle="primary" onClick={this.edit} hidden={this.state.editing}>Edit</Button>
              <Button bsStyle="primary" onClick={this.submitNewRelease} hidden={!this.state.editing}>Save</Button>
              <Button bsStyle="primary" onClick={this.loadReleaseFromServer} hidden={!this.state.editing}>Cancel</Button>
            </Col>
          </div>
        </form>
      </Panel>
    )
  }
})
