# rake decko:docs:...

# NOTE: for the moment these are Platypus tasks.
# Until they're more monkey friendly, let's not write descriptions
#
# Make sure: you're:
#   (A) running in a development environment, and
#   (B) pointing to a repo gem
namespace :decko do
  namespace :docs do
    # trigger tmpsets and then run yardoc
    task :update do
      Rake::Task["decko:docs:trigger_tmpsets"].invoke
      Rake::Task["decko:docs:yardoc"].invoke
    end

    # We have to load the environment with `env DECKO_DOC_MODE=true` in
    # development mode to trigger the tmpset generation.
    # There's probably a more elegant way?
    task :trigger_tmpsets do
      ENV["DECKO_DOC_MODE"] = "true"
      Rake::Task["decko:docs:dummy"].invoke
    end

    # just load environment and trigger Card load
    task dummy: :environment do
      Card
    end

    # run yardoc command, which generates the docs content in the repo root
    #
    # If you run this while decko is a gem, you could get some funky docs in
    # your gems directory...
    task :yardoc do
      doc_dir = File.expand_path "..", Decko.gem_root
      system %(cd #{doc_dir}; yardoc)
    end
  end
end
