# -*- encoding : utf-8 -*-
#
require "./decko_gem"

# Note: these tasks are not in any gem and are thus not available to mod
# developers.  Therefore they should contain only tasks for core developers.

task :push_gems do
  # push_main_gems
  push_mod_gems
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

def push_gem gem, version
  %(
    rm *.gem
    gem build #{gem}.gemspec
    gem push #{gem}-#{version}.gem
  )
end

def push_main_gems
  %w(card cardname decko).each do |gem|
    v = gem == "card" ? DeckoGem.card_version : version
    system %(cd #{gem}; #{push_gem gem, v})
  end
end

def push_mod_gems
  %w(edit ace_editor prosemirror_editor tinymce_editor date recaptcha).each do |gem|
    gem = "card-mod-#{gem}"
    system %(cd #{gem}; #{push_gem gem, version})
  end
end

def version
  DeckoGem.version
end
