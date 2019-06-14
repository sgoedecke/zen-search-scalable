require 'json'
require 'oj'

class IndexBuilder < ::Oj::ScHandler
  def initialize(file, field_to_index, index = {})
    @field_to_index = field_to_index
    @file = file
    @index = index
    @start = 0
    @end = 0
  end

  def hash_start()
    @start = @file.pos
    {}
  end

  def hash_end()
    puts "ENDING #{@last_value}"
    @end = @file.pos
    if @end == @start
      puts "DUPLICATE!!! #{@end}"
      puts "INDEX IS #{@index[@last_value]}"
    end
    @index[@last_value] << @end

  end

  def hash_set(hash, key, value)
    if key == @field_to_index
      @index[value] = [@start]
      @last_value = value
      hash[key] = value
    end
  end
end


class Search
  def initialize
    index = build_index('tickets', '_id')
  #  res = search('tickets', '8d7b4d51-ef95-4923-9ab8-42332ab2188d', index)
   # puts res
  end

  def search(file, id, index)
    offset = index[id]
    File.open("#{file}.db") do |f|
      f.seek(offset, IO::SEEK_SET)
      f.readline
    end
  end

  private

  def build_index(file, field_to_index)
    @index = {}
    File.open("data/#{file}.json", 'r') do |f|
      b = IndexBuilder.new(f, '_id', @index)

      Oj.sc_parse(b, f)
    end
    puts @index
  end

end

Search.new
