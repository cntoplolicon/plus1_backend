get '/events/lastest' do
  @event = Event.order(:created_at).first
  halt json({}) unless @event
  rabl_json :event
end
