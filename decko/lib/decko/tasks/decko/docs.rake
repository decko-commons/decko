require "pry"

namespace :decko do
  namespace :docs do
    task :update do
      ENV["DECKO_DOC_MODE"] = "true"
      Rake::Task["environment"].invoke
      Rake::Task["decko:docs:yardoc"].execute
      Card
    end

    # We
    task trigger_tmpsets: :environment do
      Card
    end

    task :yardoc do
      doc_dir = File.expand_path "..", Decko.gem_root
      system %(cd #{doc_dir}; yardoc)
    end
  end
end
