require 'yaml'

module Ui
  class Search
    def initialize(models)
      @models = models
    end

    def tables
      @models.keys
    end

    def run
      loop do
        table = prompt("Enter a table to search (#{tables.join(', ')}), or Ctrl+C to exit:")
        if tables.include?(table)
          key = prompt("Enter a key to search for:")
          value = prompt("Enter a value to search for (under key #{key}):")
          res = @models[table].search(key, value)
          display_result(res)
        else
          puts "Sorry, could not recognize table name #{table}"
        end
      end
    end

    def prompt(text)
      puts text
      gets.chomp
    end

    def display_result(res)
      if res.nil?
        puts "No results found"
      else
        puts YAML.dump(res)
      end
    end
  end
end
