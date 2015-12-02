const React = require('react')
const {Input} = require('react-bootstrap')
const $ = require('jquery')

const EVENTS_URL = '/admin/events'

module.exports = React.createClass({

  getInitialState: function() {
    return {data: []}
  },

  componentDidMount: function() {
    this.loadEventsFromServer()
  },

  loadEventsFromServer: function() {
    $.ajax({
      url: EVENTS_URL,
      dataType: 'json',
      cache: false,
      success: function(data) {
        if (this.isMounted()) {
          this.setState({data: data})
        }
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(EVENTS_URL, status, err.toString())
      }.bind(this)
    })
  },

  getValue: function() {
    return this.refs.event.getValue()
  },

  render: function() {
    return (
      <Input {...this.props} ref="event" type="select">
        <option value=""></option>
        {
          this.state.data.map(function(event) {
            return <option key={event.id} value={event.id}>{event.description}</option>
          })
        }
      </Input>
    )
  }
})
