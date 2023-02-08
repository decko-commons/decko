namespace :card do
  namespace :assets do
    desc ""
    task refresh: :environment do
      Card::Assets.refresh force: true
    end

    task code: :environment do
      Cardio.config.compress_assets = true
      Card::Cache.reset_all
      Card::Assets.make_output_coded
    end

    task wipe: :environment do
      Card::Assets.wipe
    end
  end
end
