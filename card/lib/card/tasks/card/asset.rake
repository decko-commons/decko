namespace :card do
  namespace :asset do
    desc "reset style and script machine outputs"
    task :reset do
      Card::Machine.reset_all
    end

    desc "refresh style and script machine output (regenerate if needed)"
    task refresh: :environment do
      Card::Cache.reset_all
      Card::Machine.refresh_assets
      Card::Cache.reset_all # should not be necessary but breaking without...
    end

    desc "refresh style and script machine output (regenerate if needed)"
    task refresh!: :environment do
      Card::Cache.reset_all
      Card::Machine.refresh_assets!
      Card::Cache.reset_all # should not be necessary but breaking without...
    end
  end
end
