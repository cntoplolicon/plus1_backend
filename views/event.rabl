object @event

attributes :id, :description, :created_at, :logo_width, :logo_height

child :event_pages do
  attributes :id
  node :image do |page|
    image_url(page.image)
  end
end

node :logo do |event|
  image_url(event.logo)
end
