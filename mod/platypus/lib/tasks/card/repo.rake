require "rake/hooks"

namespace :card do
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
  failing_loudly "card repo update" do
    Rake::Task["card:repo:update"].invoke
  end
end
