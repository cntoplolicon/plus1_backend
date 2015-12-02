const React = require('react')
const {History} = require('react-router')
const {Input, Col, Button} = require('react-bootstrap')
const $ = require('jquery')

module.exports = React.createClass({
  mixins: [History],

  getInitialState: function() {
    return {requesting: false}
  },

  componentDidMount: function() {
    this.loadEventFromServer()
  },

  loadEventFromServer: function() {
    var url = `/admin/events/${this.props.params.eventId}`
    $.ajax({
      url: url,
      dataType: 'json',
      cache: false,
      success: function(data) {
        if (this.isMounted()) {
          this.setState({description: data.description})
        }
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(url, status, err.toString())
      }.bind(this),
    })
  },

  saveEvent: function() {
    var data = new FormData()
    var description = this.state.description
    var imageFiles = this.refs.images.getInputDOMNode().files
    var logoFile = this.refs.logo.getInputDOMNode().files[0]

    if (!description) {
      alert('description cannot be blank')
      return
    }

    data.append('description', description)
    for (var i = 0; i < imageFiles.length; i++) {
      data.append('image_files[]', imageFiles[i])
    }
    if (logoFile) {
      data.append('logo', logoFile)
    }

    var eventId = this.props.params.eventId
    var url = eventId ? `/admin/events/${eventId}` : `/admin/events`
    var method = eventId ? 'put' : 'post'

    $.ajax({
      url: url,
      method: method,
      dataType: 'json',
      processData: false,
      contentType: false,
      data: data,
      success: function(data) {
        if (this.isMounted()) {
          this.history.replaceState(null, '/events')
        }
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(url, status, err.toString())
        this.setState({requesting: false})
      }.bind(this)
    })
  },

  setDescription: function(event) {
    this.setState({description: event.target.value})
  },

  render: function() {
    return (
      <form className="form-horizontal" encType="multipart/form-data">
        <Input type="text" ref="description" label="Description" labelClassName="col-xs-2" wrapperClassName="col-xs-10"
          onChange={this.setDescription} value={this.state.description}/>
        <Input type="file" ref="images" multiple label="Images" labelClassName="col-xs-2" wrapperClassName="col-xs-10"/>
        <Input type="file" ref="logo" label="Logo" labelClassName="col-xs-2" wrapperClassName="col-xs-10"/>
        <div className="form-group">
          <Col xs={10} xsOffset={2}>
            <Button bsStyle="primary" onClick={this.saveEvent} disabled={this.state.requesting}>Save</Button>
          </Col>
        </div>
      </form>
    )
  }
})
