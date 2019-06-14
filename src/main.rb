require_relative './db/base'
require_relative './ui/search'

# require_relative './db/naive/base'
# Swap out Db::Base with Db::Naive::Base to compare memory usage
# with a naive in-memory data store implementation

class Runner
  def run
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
    Ui::Search.new({
      'users' => users,
      'organizations' => organizations,
      'tickets' => tickets
    }).run
  end
end

Runner.new.run

