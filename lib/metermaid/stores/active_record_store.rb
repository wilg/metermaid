require 'active_record'

module Metermaid

  module DB
    class Sample < ActiveRecord::Base
      validates :sample_hash, uniqueness: true
    end
  end

  class ActiveRecordStore < Store

    def migration_path
      File.join(
        File.dirname(__FILE__),
        "..",
        "..",
        "..",
        "db/migrate"
      )
    end

    def open!
      ActiveRecord::Base.table_name_prefix = 'metermaid_'
      ActiveRecord::Base.logger = Logger.new(STDERR)
      conn = ENV["DATABASE_URL"] || {
        adapter: "postgresql",
        encoding: "unicode",
        host: "localhost",
        database: "metermaid"
      }
      ActiveRecord::Base.establish_connection(conn)
      migrate!
    end

    def migrate!
      ActiveRecord::Migration.verbose = true
      ActiveRecord::Migrator.migrate(migration_path)
    end

    def reset!
      ActiveRecord::Migration.verbose = true
      ActiveRecord::Migrator.migrate(migration_path, 0)
    end

    def close!
      if (ActiveRecord::Base.connection && ActiveRecord::Base.connection.active?)
         ActiveRecord::Base.connection.close
      end
    end

    def add_headlines!(source_id, headlines)
      deduplicated = []
        headlines.uniq{|h| h.hash}.each do |h|
          begin
            headline = DB::SourceHeadline.new({
              name_hash:    h.hash,
              name:         h.name,
              url:          h.url,
              published_at: h.date,
              fetcher:      'headline-sources-active-record',
              source_id:    source_id,
              author:       h.author,
              section:      h.section,
            })
            headline.save!
            deduplicated << h
          rescue => e
            puts e.message.red
          end
        end
      deduplicated
    end

  end
end
