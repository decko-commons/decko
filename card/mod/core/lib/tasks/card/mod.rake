namespace :card do
  namespace :mod do
    desc "list current mods in load order"
    task list: :environment do
      Cardio.mods.each { |m| puts "#{m.name}: #{m.path}".green }
    end

    desc "symlink from deck public/{modname} to mod's public directory"
    task symlink: :environment do
      FileUtils.rm_rf public_mod_dir
      FileUtils.mkdir_p public_mod_dir
      Cardio::Mod.dirs.each_subpath "public" do |mod, target|
        link = public_mod_dir mod
        FileUtils.rm_rf link
        FileUtils.ln_sf target, link
      end
    end

    desc "list mods still installed but not configured for use"
    task leftover: :environment do
      Cardio::Mod.leftover.each { |m| puts m.modname.yellow }
    end

    desc "uninstall leftover mods"
    task uninstall: :environment do
      Cardio::Mod.ensure_uninstalled
    end

    desc "install all mods"
    task install: :environment do
      # Cardio.config.compress_assets = true # should not be here, imo #efm
      Cardio::Mod.ensure_installed
    end

    private

    def public_mod_dir subdir=nil
      File.join(*[Rails.public_path, "mod", subdir].compact)
    end
  end
end
