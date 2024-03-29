require 'json'

# An append-only db with an in-memory index. Reads on the index key go to the
# index, all other reads perform a full scan of the heap file. The heap file does
# not need to fit in-memory, but the index must (so be careful about indexing on
# fields with very large values).
#
# Usage:
# ```
# conn = Db::Store.new
# conn.write({'a' => 1, 'b' => '123', '_id' => 666})
# conn.write({'foo' => 'bar', '_id' => 777})
# conn.read('_id', 777)
# conn.read('b', 123)
# conn.close
# ```
module Db
  class Store
    def initialize(heap_filename = 'heap.db', index_key = '_id')
      # TODO: support loading heap/index from file
      # TODO: support multiple indexes
      @heap = File.open(heap_filename, 'w+')
      @index_key = index_key
      @index = {}
    end

    def write(record)
      # since reading can move the file cursor around, we seek to the end 
      # of file here to ensure we only ever append
      @heap.seek(0, IO::SEEK_END)
      cursor = @heap.pos
      index_val = record[@index_key]
      @index[index_val.to_s] = cursor unless index_val.nil?
      @heap << "#{record.to_json}\n"
    end

    def read(key, value)
      if key == @index_key
        read_from_index(key, value)
      else
        read_from_heap_scan(key, value)
      end
    end

    private

    def read_from_index(key, value)
      pos = @index[value.to_s]
      return nil unless pos

      # seek to the byte offset stored in the index and return the whole line
      @heap.seek(pos, IO::SEEK_SET)
      JSON.parse(@heap.readline)
    end

    def read_from_heap_scan(key, value)
      @heap.seek(0) # since we're traversing the whole file, seek to the beginning
      @heap.each_line do |line|
        # to avoid unencoding each line, do a string match first to rule out obvious misses
        next unless line.include?(value) && line.include?(key)
        record = JSON.parse(line)
        return record if matches?(record[key], value)
      end
      return nil
    end

    def matches?(a, b)
      return true if a.to_s == b.to_s
      return true if a.is_a?(Array) && b.include?(value)
      false
    end
  end
end

