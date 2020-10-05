#!/usr/bin/env ruby

DECKS_DIR = "/home/semaphore/decks"
VERB = ARGV.shift

Dir.chdir DECKS_DIR

system %(git submodule > substat.txt)

File.read("#{DECKS_DIR}/substat.txt").split("\n") do |line|
  hash = line.match(/^.(?<sha>\S*) (?<path>\S*)/)
  system "cache #{VERB} git-submodule-#{hash[:sha]} #{hash[:path] if VERB == 'store'}"
end
