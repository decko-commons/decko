#!/usr/bin/env ruby

VERB = ARGV.shift || fail("verb required")
STATUS_FILE = File.expand_path "#{ENV["DECKO_REPO_PATH"]}/substat.txt"
STATUS_REGEXP = %r{^.(?<sha>\S*) (?<path>\S*)}

# Loop through each git submodule and handle semaphore caching

# Note, this was previously attempted with `git submodule foreach`, but that
# commands assumes submodules have already been cloned with `git submodule update`.
# The point of this optimization is to prevent cloning, so instead we use
# `git submodule status` to produce a status file (one that is also used in other
# semaphore job commands), and then parse that file to get the sha and path we
# need for caching.

File.read(STATUS_FILE).split("\n") do |line|
  hash = line.match STATUS_REGEXP
  system "cache #{VERB} git-submodule-#{hash[:sha]} #{hash[:path] if VERB == 'store'}"
end
