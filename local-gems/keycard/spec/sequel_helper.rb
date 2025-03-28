# frozen_string_literal: true

# Require this helper in tests that need to use the database.
# Also remember to tag the example groups with `DB: true` so each one is
# wrapped in a transaction that rolls back to handle cleanup.

require 'spec_helper'
require 'keycard/db'

unless Keycard::DB.connected?
  if Keycard::DB.conn_opts.empty?
    Keycard::DB.connect!(db: Sequel.sqlite)
    Keycard::DB.migrate!
  end
end
Keycard::DB.initialize!

RSpec.configure do |config|
  config.around(:each, DB: true) do |example|
    Keycard::DB.db.transaction(rollback: :always, auto_savepoint: true) do
      example.run
    end
  end
end
