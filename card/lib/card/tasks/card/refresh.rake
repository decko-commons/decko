namespace :card do

  desc "refresh machine output"
  task refresh_machine_output: :environment do
    Card.reset_all_machines
    Card::Auth.as_bot do
      [%i[all script],
       %i[all style],
       %i[script_html5shiv_printshiv]].each do |name_parts|
        Card[*name_parts].update_machine_output
      end
    end
    Card::Cache.reset_all # should not be necessary but breaking without...
  end

  task clean_machines: :environment do
    clean_machines
  end

  def clean_machines
    puts "clean machines"
    Card.reset_all_machines
    reseed_machine_output
    clean_inputs_and_outputs
  end

  desc "update decko gems and database"
  task :update do
    failing_loudly "decko update" do
      ENV["NO_RAILS_CACHE"] = "true"
      decko_namespace["migrate"].invoke
      decko_namespace["reset_tmp"].invoke
      Card::Cache.reset_all
      decko_namespace["update_assets_symlink"].invoke
    end
  end

end
