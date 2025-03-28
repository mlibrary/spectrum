# frozen_string_literal: true

# This is a rather odd spec file because its purpose is to test that the config
# handling/startup is working as expected. The rest of the tests that depend on
# the database just require 'sequel_helper', which handles the setup. This
# group has to do a lot of fiddling to both verify the behavior and cooperate
# with the other tests.

require 'sequel_helper'
require 'yaml'

RSpec.describe Keycard::DB do
  before(:each) { unset_database }
  after(:each)  { restore_database }

  describe '.connect!' do
    it 'connects with a URL string' do
      Keycard::DB.connect!(url: 'mock:///')
      expect(Keycard::DB.db.adapter_scheme).to eq :mock
    end

    it 'connects with an options hash' do
      Keycard::DB.connect!(opts: { adapter: 'sqlite' })
      expect(Keycard::DB.db.adapter_scheme).to eq :sqlite
    end

    it 'returns the database' do
      db = Keycard::DB.connect!(url: 'mock:///')
      expect(db).to eq Keycard::DB.db
    end

    it 'can use an existing connection' do
      db = Sequel.sqlite
      Keycard::DB.connect!(db: db)
      expect(db).to equal Keycard::DB.db
    end

    it 'raises a connection error on a bad URL' do
      expect { Keycard::DB.connect!(url: 'badurl') }.to raise_error StandardError
    end

    it 'raises an error with no connection information' do
      expect { Keycard::DB.connect! }.to raise_error Keycard::DB::DatabaseError
    end
  end

  describe '.initialize!' do
    describe 'migration check' do
      it 'raises an error if migrations have not been run' do
        allow(Keycard::DB).to receive(:model_files).and_return(['../../spec/support/migration_check'])
        expect do
          db = Sequel.sqlite
          Sequel::Model.db = db
          Keycard::DB.connect!(db: db)
          Keycard::DB.initialize!
        end.to raise_error Keycard::DB::DatabaseError
      end

      # This is just a sanity check for the testing environment.
      # MigrationCheck raises an error if it's already defined to be paranoid
      # about any class reloading bugs. It exists only to support the above test.
      it 'only allows MigrationCheck to be required once' do
        expect do
          require_relative('../support/migration_check')
        end.to raise_error RuntimeError
      end
    end
  end

  describe '.migrate!' do
    it 'creates the tables to support the models and initialization' do
      db = Sequel.sqlite
      Keycard::DB.connect!(db: db)
      Keycard::DB.migrate!
      expect(db[:aa_inst].columns).to_not be nil
    end
  end

  describe '.dump_schema!' do
    before(:each) do
      db = Sequel.sqlite
      db.create_table(:keycard_schema) { int :version }
      db[:keycard_schema].insert(version: 1)
      Keycard::DB.connect!(db: db)
    end

    after(:each) { restore_database }

    it 'writes the schema version to db/keycard.yml' do
      expect(File)
        .to receive(:write)
        .with('db/keycard.yml', Keycard::DB::SCHEMA_HEADER + "---\n:version: 1\n")

      Keycard::DB.dump_schema!
    end
  end

  describe '.load_schema!' do
    before(:each) do
      db = Sequel.sqlite
      db.create_table(:keycard_schema) { int :version }
      Keycard::DB.connect!(db: db)
    end

    after(:each) { restore_database }

    it 'inserts the schema version from db/keycard.yml' do
      expect(YAML).to receive(:load_file).with('db/keycard.yml').and_return(version: 1)
      Keycard::DB.load_schema!
      version = Keycard::DB[:keycard_schema].get(:version)
      expect(version).to eq 1
    end
  end

  describe '.model_files' do
    it 'lists its model files' do
      expect(Keycard::DB.model_files).to be_an Array
    end
  end

  describe '.merge_config!' do
    it 'adds a url to the config' do
      Keycard::DB.merge_config!(url: 'url')
      expect(Keycard::DB.config.url).to eq 'url'
    end

    it 'adds opts to the config' do
      opts = { adapter: 'sqlite' }
      Keycard::DB.merge_config!(opts: opts)
      expect(Keycard::DB.config.opts).to eq opts
    end

    it 'adds db to the config' do
      db = double('database')
      Keycard::DB.merge_config!(db: db)
      expect(Keycard::DB.config.db).to eq db
    end

    it 'does not add arbitrary keys' do
      Keycard::DB.merge_config!(foo: 'bar')
      expect(Keycard::DB.config.foo).to be_nil
    end
  end

  describe '.conn_opts' do
    context 'when a URL is configured' do
      before(:each) { Keycard::DB.config.url = 'url' }

      it 'gives the url as the first element' do
        expect(Keycard::DB.conn_opts.first).to eq 'url'
      end

      it 'gives the logger as the only element of the options' do
        opts = Keycard::DB.conn_opts.last
        expect(opts.size).to eq 1
        expect(opts).to have_key :logger
      end
    end

    context 'when a URL is not configured' do
      it 'only returns the opts hash' do
        Keycard::DB.config.opts = {}
        expect(Keycard::DB.conn_opts.size).to eq 1
      end

      it 'uses any configured options' do
        Keycard::DB.config.opts = { foo: 'bar' }
        expect(Keycard::DB.conn_opts.first).to have_key(:foo)
      end

      it 'merges the default logger into the options' do
        Keycard::DB.config.opts = {}
        expect(Keycard::DB.conn_opts.first).to have_key(:logger)
      end

      it 'does not overwrite a supplied logger' do
        logger = double('logger')
        Keycard::DB.config.opts = { logger: logger }
        expect(Keycard::DB.conn_opts.first[:logger]).to equal logger
      end
    end
  end

  describe '.config' do
    before(:each) do
      # This is a special case because it's a caching assignment to do the ENV
      # lookups. For all the other tests, we just use an empty OpenStruct
      Keycard::DB.instance_variable_set(:@config, nil)
    end

    after(:each) { restore_database }

    it 'picks up a DATABASE_URL in the ENV with no explicit action' do
      allow(ENV).to receive(:[]).and_return(nil)
      allow(ENV).to receive(:[]).with('DATABASE_URL').and_return('url')
      expect(Keycard::DB.config.url).to eq 'url'
    end

    it 'picks up a KEYCARD_DATABASE_URL in the ENV with no explicit action' do
      allow(ENV).to receive(:[]).and_return(nil)
      allow(ENV).to receive(:[]).with('KEYCARD_DATABASE_URL').and_return('url')
      expect(Keycard::DB.config.url).to eq 'url'
    end

    it 'prefers KEYCARD_DATABASE_URL to DATABASE_URL' do
      allow(ENV).to receive(:[]).with('DATABASE_URL').and_return('bad')
      allow(ENV).to receive(:[]).with('KEYCARD_DATABASE_URL').and_return('url')
      expect(Keycard::DB.config.url).to eq 'url'
    end

    it 'is nil when no URL is in the ENV' do
      allow(ENV).to receive(:[]).and_return(nil)
      expect(Keycard::DB.config.url).to be_nil
    end
  end

  describe '.db' do
    it 'raises an error if not yet connected' do
      expect do
        Keycard::DB.db
      end.to raise_error Keycard::DB::DatabaseError
    end
  end

  describe '[]' do
    it 'passes everything on to db' do
      db = double('database')
      Keycard::DB.connect!(db: db)
      expect(db).to receive(:[]).with(:table)
      Keycard::DB[:table]
    end
  end

  def unset_database
    @db     = Keycard::DB.db
    @config = Keycard::DB.config
    Keycard::DB.instance_variable_set(:@db, nil)
    Keycard::DB.instance_variable_set(:@config, OpenStruct.new)
    Sequel::Model.db = nil
  end

  def restore_database
    Keycard::DB.instance_variable_set(:@db, @db)
    Keycard::DB.instance_variable_set(:@config, @config)
    Sequel::Model.db = @db
  end
end
