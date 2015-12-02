get '/events/latest' do
  @event = Event.order(created_at: :desc).first
  halt json({}) unless @event
  rabl_json :event
end

get '/events' do
  @events = Event.all.order(created_at: :desc)
  rabl_json :events
end