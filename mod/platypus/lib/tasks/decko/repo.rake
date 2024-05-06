require "rake/hooks"

namespace :decko do
  namespace :repo do
    desc "list the status of all git submodules"
    task status: :environment do
      system "git -C #{Decko.gem_root} submodule status"
    end

    desc "update all git submodules"
    task update: :environment do
      puts "updating git submodules"
      system "git -C #{Decko.gem_root} submodule update --init --recursive"
    end
  end
end

before "card:update" do
  failing_loudly "decko repo update" do
    Rake::Task["decko:repo:update"].invoke
  end
end
