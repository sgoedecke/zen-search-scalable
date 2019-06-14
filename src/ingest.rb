require 'oj'

# A SCP JSON parser that writes finished top-level objects to a db as it goes
class IngestHandler < ::Oj::ScHandler
  def initialize(db)
    @db = db
  end

  def hash_start
    {}
  end

  def hash_set(h,k,v)
    h[k] = v
  end

  def array_start
    []
  end

  def array_append(a,v)
    a << v
    # Make sure we only write an object to the db, not (e.g.) string tags
    @db.write(v) if v.is_a?(Hash)
  end

  def error(message, line, column)
    puts "PARSING ERROR: #{message}"
  end
end

# A pipeline that dumps large JSON files into our db without loading the whole
# contents into memory at one time.
class IngestionPipeline
  def initialize(db)
    @db = db
  end

  def ingest(filename)
    File.open(filename, 'r') do |f|
      Oj.sc_parse(IngestHandler.new(@db), f)
    end
  end
end
