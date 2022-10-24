# rubocop:disable Metrics/AbcSize
require 'multi_json'

module Rulers
  module Model
    class FileModel
      def initialize(filename)
        @filename = filename

        # if filename is 'dir/37.json', @id = 37
        basename = File.split(filename)[-1]
        @id = File.basename(basename, '.json').to_i

        obj = File.read(filename)
        @hash = MultiJson.load(obj)
      end

      def [](name)
        @hash[name.to_s]
      end

      def []=(name, value)
        @hash[name.to_s] = value
      end

      def self.find(id)
        FileModel.new("db/quotes/#{id}.json")
      rescue StandardError
        nil
      end

      def self.all
        files = Dir['db/quotes/*.json']
        files.map { |f| FileModel.new(f) }
      end

      def self.create(attrs)
        hash = {}
        hash['submitter'] = attrs['submitter'] || ''
        hash['quote'] = attrs['quote'] || ''
        hash['attribution'] = attrs['attribution'] || ''

        files = Dir['db/quotes/*.json']
        names = files.map { |f| f.split('/')[-1] }
        highest = names.map { |b| b[0..-5].to_i }.max
        id = highest + 1

        File.write("db/quotes/#{id}.json", <<-TEMPLATE)
          {
            "submitter": "#{hash['submitter']}",
            "quote": "#{hash['quote']}",
            "attribution": "#{hash['attribution']}"
          }
        TEMPLATE

        FileModel.new "db/quotes/#{id}.json"
      end
    end
  end
end

# rubocop:enable Metrics/AbcSize
