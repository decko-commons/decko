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
      Rake::Task["decko:tmpsets:trigger"].invoke
      Rake::Task["decko:docs:yardoc"].invoke
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
