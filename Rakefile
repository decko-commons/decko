# -*- encoding : utf-8 -*-

require "./decko_gem"

DOCKER_IMAGES = %w[base bundled mysql postgres sandbox].map { |name| "decko-#{name}" }

# DOCKER_IMAGES = ["decko-base", "decko-bundled"]

# NOTE: these tasks are not in any gem and are thus not available to monkeys.
# Therefore they should contain only platypus tasks.

task :push_gems do
  each_gem do |dir, gem|
    gem ||= dir
    v = gem == :card ? DeckoGem.card_version : version
    system %(cd #{dir}; #{push_gem gem, v})
  end
end

task :version do
  puts version
end

task :release do
  system %(
    git tag -a v#{version} -m "Decko Version #{version}"
    git push --tags decko
  )
end

# do NOT use `bundle exec` or bundle update won't work
task :build_images do
  # system "docker pull phusion/passenger-full:latest"
  # system "cd docker/template; bundle update"

  DOCKER_IMAGES.each do |i|
    system "echo '\nBUILDING: #{i}'"
    system "cd docker; "\
           "docker build -f repos/#{i}.dockerfile "\
           "-t ethn/#{i} -t ethn/#{i}:latest -t ethn/#{i}:v#{version} ."
    system "docker push ethn/#{i}:latest"
    system "docker push ethn/#{i}:v#{version}"
  end
end

# task :retag_latest do
#   DOCKER_IMAGES.each do |i|
#     i = "ethn/#{i}"
#     system "docker pull #{i}:v#{version}"
#     system "docker tag #{i}:v#{version} #{i}:latest"
#     system "docker push #{i}:latest"
#   end
# end

#------ Support methods -----------

def each_gem
  yield :cardname
  yield :card
  Dir.each_child("mod") { |mod| yield "mod/#{mod}", "card-mod-#{mod}" }
  yield :decko
  Dir.each_child("support") { |lib| yield "support/#{lib}", lib }
end

def push_gem gem, version, prefix=""
  %(
    rm *.gem
    gem build #{prefix}#{gem}.gemspec
    gem push #{prefix}#{gem}-#{version}.gem
  )
end

def version
  DeckoGem.decko_version
end
