
namespace :card do
  desc "reset cache"
  task reset_cache: :environment do
    Card::Cache.reset_all
  end

  desc "reset machine output"
  task reset_machine_output: :environment do
    Card.reset_all_machines
  end

  desc "reset with an empty tmp directory"
  task :reset_tmp do
    tmp_dir = Decko.paths["tmp"].first
    if Decko.paths["tmp"].existent
      Dir.foreach(tmp_dir) do |filename|
        next if filename.starts_with? "."
        FileUtils.rm_rf File.join(tmp_dir, filename), secure: true
      end
    else
      Dir.mkdir tmp_dir
    end
  end
end
