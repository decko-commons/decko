namespace :card do
  namespace :mod do
    desc "symlink from deck public/{modname} to mod's public directory"
    task symlink: :environment do
      Cardio::Mod.dirs.each_public_path do |mod, target|
        link = File.join Rails.public_path, mod
        FileUtils.rm_rf link
        FileUtils.ln_s target, link, force: true
      end
    end

    desc "install all mods"
    task install: :environment do
      Card::Machine.reset_script
      Card::Cache.reset_all
      puts "installing card mods".green
      Cardio::Mod.dirs.mods.each do |mod|
        mod.ensure_mod_installed
        Card::Cache.reset_all
      end
    end
  end
end
