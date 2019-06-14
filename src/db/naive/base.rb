# Naive in-memory data store, used for comparison when profiling
# With ~60MB of data, uses ~30x the memory of the non-naive version
# (723MB vs 25 MB)

module Db
  module Naive
    class Base
      def initialize
        @data = []
      end

      def ingest(source_filename)
        @data = JSON.parse(File.read(source_filename))
      end

      def search(key, value)
        record = @data.find do |r|
          r[key] == value || (r[key].is_a?(Array) && r[key].include?(value))
        end
        # UNIMPLEMENTED: related record fetching

        record
      end

      def set_foreign_keys(keys)
        # noop
      end
    end
  end
end
