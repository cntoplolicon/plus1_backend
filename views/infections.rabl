collection @infections

attributes :id
node :post do |infection|
  partial('post', object: infection.post)
end
