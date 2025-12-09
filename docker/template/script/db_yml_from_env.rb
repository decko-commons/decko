#!/usr/bin/env ruby

require "erb"

FILENAME = "/deck/config/database.yml".freeze

ENGINES = {
  mysql: :mysql2,
  postgres: :postgresql,
  sqlite: :sqlite3
}.freeze

engine = ENV["DECKO_DB_ENGINE"]&.to_sym || :mysql

string = File.read "#{FILENAME}.erb"

# define input for erb file
adapter = ENGINES[engine]
username = engine == :postgres ? :postgres : :root

rendered = ERB.new(string).result(binding)

File.write FILENAME, rendered
