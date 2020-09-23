require "decko/application"
require_relative "alias"

CARD_TASKS =
  [
    :add,
    :add_remote,
    { create: [:codefile, :haml, :script, :style] },
    { grab: [:deep_pull, :deep_pull_items, :pull, :pull_export] },
    { merge: [:merge, :merge_all] },
    :migrate,
    { migrate: [:cards, :structure, :core_cards, :deck_cards,
       :deck_structure, :redo, :stamp] },
    :refresh_machine_output,
    :reset_cache,
    :reset_machine_output,
    :reset_tmp,
    #{ seed: [:assume_card_migrations, :clean, :clear, :dump, :emergency,
    #   :fixtures, :load, :reseed, :seed, :supplement, :update] },
    :seed,
    { seed: [:assume_card_migrations, :clean, :clear, :dump,
       :load, :reseed, :supplement, :update] },
    :update,
    :reset_cache
  ]

link_task CARD_TASKS, from: :decko, to: :card

decko_namespace = namespace :decko do
  desc "set symlink for assets"
  task update_assets_symlink: :environment do
    prepped_asset_path do |assets_path|
      Card::Mod.dirs.each_assets_path do |mod, target|
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
