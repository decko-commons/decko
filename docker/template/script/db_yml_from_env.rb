#!/usr/bin/env ruby

require 'erb'

FILENAME = "/deck/config/database.yml"

ENGINES = {
  mysql: :mysql2,
  postgres: :pg,
  sqlite: :sqlite3
}

string = File.read "#{FILENAME}.erb"
adapter = ENGINES[ENV["DECKO_DB_ENGINE"]&.to_sym] || "mysql2"
rendered = ERB.new(string).result

File.write FILENAME, rendered
