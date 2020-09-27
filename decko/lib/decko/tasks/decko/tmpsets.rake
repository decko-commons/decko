namespace :decko do
  namespace :tmpsets do
    # We have to load the environment with `env DECKO_GEM_TMPSETS=true` in
    # development mode to trigger the tmpset generation.
    # There's probably a more elegant way?
    task :trigger do
      ENV["DECKO_GEM_TMPSETS"] = "true"
      Rake::Task["decko:tmpsets:dummy"].invoke
    end

    # just load environment and trigger Card load
    task dummy: :environment do
      Card
    end

    task :copy do
      require "fileutils"
      require "cardio"

      target = "#{Cardio.gem_root}/tmpsets"
      FileUtils.rm_r Dir["#{target}/set*"]
      FileUtils.cp_r Dir["#{Cardio.root}/tmpsets/set*"], "#{Cardio.gem_root}/tmpsets"
    end
  end
end
