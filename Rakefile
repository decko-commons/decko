# -*- encoding : utf-8 -*-

require "./decko_gem"

DOCKER_IMAGES = %w[base bundled mysql postgres sandbox].map { |name| "decko-#{name}" }

# NOTE: these tasks are not in any gem and are thus not available to mod
# developers.  Therefore they should contain only tasks for core developers.

task :push_gems do
  each_gem do |gem|
    v = gem == :card ? DeckoGem.card_version : version
    system %(cd #{gem}; #{push_gem gem, v})
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

task :build_images do
  # system "docker pull phusion/passenger-full:latest"
  system "cd docker/template; bundle update"

  DOCKER_IMAGES.each do |i|
    system "cd docker; "\
           "docker build -f repos/#{i}.dockerfile -t ethn/#{i} -t ethn/#{i}:v#{version} ."
  end
end

task :push_images do
  DOCKER_IMAGES.each do |image|
    system "docker push ethn/#{image}"
  end
end

def each_gem &block
  yield :card
  Dir.each_child "mod", &block
  yield :decko
  Dir.each_child "support", &block
end

def push_gem gem, version
  %(
    rm *.gem
    gem build #{gem}.gemspec
    gem push #{gem}-#{version}.gem
  )
end

def version
  DeckoGem.decko_version
end
