namespace :card do
  namespace :mod do
    desc "symlink from deck public/{modname} to mod's public directory"
    task symlink: :environment do
      FileUtils.mkdir_p public_mod_dir unless File.exist? public_mod_dir
      Cardio::Mod.dirs.each_public_path do |mod, target|
        link = public_mod_dir mod
        FileUtils.rm_rf link
        FileUtils.ln_sf target, link
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

    def public_mod_dir subdir=nil
      parts = [Rails.public_path, "mod", subdir].compact
      File.join(*parts)
    end
  end
end
