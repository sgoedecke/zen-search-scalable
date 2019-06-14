require_relative './db'
require_relative './ingest'

conn = Db.new
ingestion = IngestionPipeline.new(conn)
ingestion.ingest('users.json')
puts conn.read('_id', 75)
puts conn.read('alias', 'Miss Rosanna')
conn.close
