require "decko/application"
require "tasks/alias"
require "card/seed_consts"

CARD_TASKS =
  [
    :dump,
    :migrate,
    { migrate: [:structure, :deck_structure,
        :cards, :core_cards, :deck_cards, :redo, :stamp] },
    :refresh_machine_output,
    :reset_cache,
    :reset_machine_output,
    :reset_tmp,
    :seed,
    { seed: [:clear, :load, :reseed] },
    :supplement,
    :update
  ]

link_task CARD_TASKS, from: :decko, to: :card

decko_namespace = namespace :decko do
  desc "update decko gems and database"
  task :update do
    failing_loudly "decko update" do
      ENV["NO_RAILS_CACHE"] = "true"
      Rake::Task["card:migrate"].invoke
      Rake::Task["card:reset_tmp"].invoke
      Card::Cache.reset_all
      decko_namespace["update_assets_symlink"].invoke
    end
  end

  desc "set symlink for assets"
  task update_assets_symlink: :environment do
    prepped_asset_path do |assets_path|
      Cardio::Mod.dirs.each_assets_path do |mod, target|
        link = File.join assets_path, mod
        FileUtils.rm_rf link
        FileUtils.ln_s target, link, force: true
      end
    end
  end

  def prepped_asset_path
    return if Rails.root.to_s == Decko.gem_root # inside decko gem
    assets_path = File.join Rails.public_path, "assets"
    if File.symlink?(assets_path) || !File.directory?(assets_path)
      FileUtils.rm_rf assets_path
      FileUtils.mkdir assets_path
    end
    yield assets_path
  end
end

def version
  ENV["VERSION"] ? ENV["VERSION"].to_i : nil
end
