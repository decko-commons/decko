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

  desc "update decko gems and database"
  task :update do
    failing_loudly "decko update" do
      ENV["NO_RAILS_CACHE"] = "true"
      Rake::Task["card:migrate"].invoke
      Rake::Task["card:reset_tmp"].invoke
      Card::Cache.reset_all
    end
  end

end
