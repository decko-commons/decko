# -*- encoding : utf-8 -*-
#
require "./decko_gem"

DOCKER_IMAGES = %w[base bundled mysql postgres sandbox].map { |name| "decko-#{name}" }

# Note: these tasks are not in any gem and are thus not available to mod
# developers.  Therefore they should contain only tasks for core developers.

task :push_gems do
  each_gem do |gem|
    v = gem == "card" ? DeckoGem.card_version : version
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
  system "docker pull phusion/passenger-full:latest"
  system "cd docker/template; bundle update"

  # TODO: add version-specific tags to images
  DOCKER_IMAGES.each do |image|
    system "cd docker; docker build -f repos/#{image}.dockerfile -t ethn/#{image} ."
  end
end

task :push_images do
  DOCKER_IMAGES.each do |image|
    system "docker push ethn/#{image}"
  end
end

def each_gem
  %w[card decko].map do |prefix|
    Dir.glob("#{prefix}*").each do |gem|
      yield gem
    end
  end
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
