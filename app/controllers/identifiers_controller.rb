class IdentifiersController < ApplicationController
  def convert(identifiers, databases)
    @identifiers, @databases = identifiers, databases
    @hits_count    = Identifier.count(identifiers, databases)

    respond_to do |format|
      format.js do
        @display_count = [@hits_count, 100].min
        @db_links = Identifier.convert(identifiers, databases)
      end

      format.csv do
        @database_labels = databases.map {|db| Database.find(db)['label'] }
        @filename = 'identifiers.csv'
        @streaming = true
      end
    end
  end

  def teach(databases)
    @databases     = databases
    @db_links      = Identifier.sample(databases)
    @identifiers   = @db_links.map {|item| item[:node0].split('/').last }
    @hits_count    = Identifier.count(@identifiers, databases)
    @display_count = @db_links.count
  end
end
