object @event

attributes :id, :description, :created_at

child :event_pages do
  attributes :id
  node :image do |page|
    image_url(page.image)
  end
end
