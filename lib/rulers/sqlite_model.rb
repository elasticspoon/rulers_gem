# rubocop:disable Metrics/AbcSize
require 'sqlite3'
require 'rulers/util'

DB = SQLite3::Database.new 'test.db'

module Rulers
  module Model
    class SQLite
      def initialize(data=nil)
        @hash = data
      end

      def self.to_sql(val)
        case val
        when Numeric
          val.to_s
        when String
          "'#{val}'"
        else
          raise "Can't change #{val.class} to SQL"
        end
      end

      def self.create(values)
        values.delete 'id'
        keys = schema.keys - ['id']
        vals = keys.map do |key|
          values[key] ? to_sql(values[key]) : 'null'
        end

        DB.execute <<~SQL
          INSERT INTO #{table} (#{keys.join ','})
          VALUES (#{vals.join ','});
        SQL

        data = (keys.zip vals).to_h
        sql = 'SELECT last_insert_rowid();'
        data['id'] = DB.execute(sql)[0][0]
        new data
      end

      def self.count
        string = "SELECT COUNT(*) FROM #{table}"
        DB.execute(string)[0][0]
      end

      def self.table
        Rulers.to_underscore name
      end

      def self.schema
        return @schema if @schema

        @schema = {}
        DB.table_info(table) do |row|
          puts row.inspect
          @schema[row['name']] = row['type']
        end
        @schema
      end

      def self.find(id)
        row = DB.execute <<~SQL
          SELECT #{schema.keys.join ','} FROM #{table}
          WHERE id = #{id};
        SQL

        data = (schema.keys.zip row[0]).to_h
        new data
      end

      def [](name)
        @hash[name.to_s]
      end

      def []=(name, value)
        @hash[name.to_s] = value
      end

      def save!
        unless @hash['id']
          self.class.create
          return true
        end

        fields = @hash.map do |key, value|
          "#{key}=#{self.class.to_sql(value)}"
        end.join ','

        DB.execute <<~SQL
          UPDATE #{self.class.table}
          SET #{fields}
          WHERE id = #{@hash['id']};
        SQL

        true
      end

      def save
        save!
      rescue StandardError
        false
      end
    end
  end
end

# rubocop:enable Metrics/AbcSize
