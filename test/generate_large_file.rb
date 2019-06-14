require 'securerandom'
require 'json'

large_object = []
100000.times do |i|
  random_string = 
  large_object << {
    '_id' => i.to_s,
    'foo' => SecureRandom.alphanumeric(1000),
    'bar' => SecureRandom.alphanumeric(1000)
  }
end

File.open('large.json', 'w+') do |f|
  f << large_object.to_json
end
