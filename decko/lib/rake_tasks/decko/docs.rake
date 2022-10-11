# rake decko:docs:...

# NOTE: for the moment these are Platypus tasks.
# Until they're more monkey friendly, let's not write `desc` descriptions.
# Without those they won't show up when folks run `rake -T`
#
# Make sure: you're:
#   (A) running in a development environment, and
#   (B) pointing to a repo gem
namespace :decko do
  namespace :docs do
    # Triggers tmpsets and then runs yardoc
    #
    # IMPORTANT: Only works if using source code from github.
    task :update do
      Rake::Task["decko:tmpsets:trigger"].invoke
      Rake::Task["decko:docs:yardoc"].invoke
    end

    # Runs yardoc command, which generates the docs content in the repo root.
    #
    # IMPORTANT: Only works if using source code from github.
    # If you run this while using decko as a built gem, you could get some funky docs in
    # your gems directory...
    task :yardoc do
      doc_dir = File.expand_path "..", Decko.gem_root
      system %(cd #{doc_dir}; yardoc)
    end
  end

  namespace :tmpsets do
    # We have to load the environment with `env TMPSETS=true` in
    # development mode to trigger the tmpset generation.
    # There's probably a more elegant way?
    task :trigger do
      ENV["TMPSETS"] = "true"
      Rake::Task["decko:tmpsets:dummy"].invoke
    end

    # just load environment and trigger Card load
    task dummy: :environment do
      Card
    end
  end
end
