const React = require('react')
const {Link} =  require('react-router')
const {Table, Thumbnail} = require('react-bootstrap')
const $ = require('jquery')
const moment = require('moment')

const EventsTable = React.createClass({
  formatDate: function(str) {
    return new moment(str).format('YYYY-MM-DD HH:mm:ss')
  },

  render: function() {
    return (
      <Table striped bordered condensed hover>
        <thead>
          <tr>
            <th>id</th>
            <th>Description</th>
            <th>Created at</th>
            <th>Pages</th>
          </tr>
        </thead>
        <tbody>
          {
            this.props.events.map(function(event) {
              return (
                <tr key={event.id}>
                  <td>
                    <Link to={`/events/${event.id}/edit`}>
                      {event.id}
                    </Link>
                  </td>
                  <td>{event.description}</td>
                  <td>{this.formatDate(event.created_at)}</td>
                  <td>
                    {event.event_pages.map(function(page) {
                      return (
                        <Thumbnail key={page.id} src={page.image} className="event-thumbnail" />
                        )
                    })}
                  </td>
                </tr>
                )
            }, this)
          }
        </tbody>
      </Table>
    )
  }
})

const EVENTS_URL = '/admin/events'

module.exports = React.createClass({
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

  getInitialState: function() {
    return {data: []}
  },

  componentDidMount: function() {
    this.loadEventsFromServer()
  },

  render: function() {
    return (
      <div>
        <div className="new-link">
          <Link to={'/events/new'}>
            New Event
          </Link>
        </div>
        <EventsTable events={this.state.data} />
      </div>
    )
  }
})

