require_relative './db/base'


organizations = Db::Base.new
users = Db::Base.new
users.set_foreign_keys({'organization_id' => organizations})
users.ingest('./data/users.json')
organizations.ingest('./data/organizations.json')
puts users.search('_id', 75)
