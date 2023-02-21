namespace :card do
  namespace :assets do
    desc "regenerate asset outputs"
    task refresh: :environment do
      Card::Assets.refresh force: true
    end

    desc "update coded asset outputs"
    task code: :environment do
      Cardio.config.compress_assets = true
      Card::Cache.reset_all
      Card::Assets.make_output_coded
    end

    desc "delete all cached asset outputs and inputs"
    task wipe: :environment do
      Card::Assets.wipe
    end
  end
end
