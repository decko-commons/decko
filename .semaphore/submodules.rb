
DECKS_DIR = "~/decks"
VERB = ARGV.shift

Dir.chdir DECKS_DIR

system %(
git submodule > substat.txt
git submodule status > substat.txt
cache restore git-modules-$(checksum substat.txt)


)



def plop string
  puts string
end

def parse_line line
  line.match(/^.(?<sha>\S*) (?<path>\S*)/)
end

File.read("/tmp/wikirate-submodule.txt").split("\n") do |line|
  hash = parse_line line
  plop "cache #{VERB} git-submodule-#{hash[:sha]} #{hash[:path] if VERB == 'store'}"
end

