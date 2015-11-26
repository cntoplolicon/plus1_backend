get '/events/lastest' do
  @event = Event.order(:created_at).first
  rabl_json :event
end
