#!/usr/bin/env ruby

# Loop through each git submodule and handle semaphore caching

# Note, this was previously attempted with `git submodule foreach`, but that
# only works when

VERB = ARGV.shift || fail("verb required")
system %(git submodule > substat.txt)

File.read("#{ENV["DECKO_REPO_PATH"]}/substat.txt").split("\n") do |line|
  hash = line.match(/^.(?<sha>\S*) (?<path>\S*)/)
  system "cache #{VERB} git-submodule-#{hash[:sha]} #{hash[:path] if VERB == 'store'}"
end
