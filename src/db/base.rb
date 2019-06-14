require_relative './store'
require_relative './ingestion'

module Db
  class Base
    def initialize
      @conn = Db::Store.new(file_name)
      @foreign_keys = {}
    end

    def ingest(source_filename)
      Db::Ingestion.new(@conn).ingest(source_filename)
    end

    def search(key, value)
      record = @conn.read(key, value)
      return if record.nil?

      # TODO: include info here about which related record is which
      record[:__related] = []
      @foreign_keys.each do |key, data_store|
        record[:__related] << data_store.search('_id', record[key])
      end

      record
    end

    def set_foreign_keys(keys)
      @foreign_keys = keys
    end

    def file_name
      "./tmp/#{object_id}.db"
    end
  end
end
