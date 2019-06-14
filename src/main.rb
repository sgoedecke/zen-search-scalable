require_relative './db/base'
require_relative './ui/base'

puts "Initializing data stores..."
organizations = Db::Base.new
users = Db::Base.new
tickets = Db::Base.new
users.set_foreign_keys({'organization_id' => organizations})
tickets.set_foreign_keys({
  'submitter_id' => users,
  'assignee_id' => users,
  'organization_id' => organizations
})

puts "Ingesting data..."
users.ingest('./data/users.json')
organizations.ingest('./data/organizations.json')
tickets.ingest('./data/tickets.json')

# Begin the search loop
Ui::Base.new({
  'users' => users,
  'organizations' => organizations,
  'tickets' => tickets
}).run
