namespace :card do
  namespace :mod do
    task list: :environment do
      Cardio.mods.each do |mod|
        puts "#{mod.name}: #{mod.path}"
      end
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

    task uninstall: :environment do
      Cardio::Mod.ensure_uninstalled
    end

    desc "install all mods"
    task install: :environment do
      Cardio::Mod.ensure_installed
    end

    def public_mod_dir subdir=nil
      parts = [Rails.public_path, "mod", subdir].compact
      File.join(*parts)
    end
  end
end
