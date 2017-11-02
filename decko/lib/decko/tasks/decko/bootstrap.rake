namespace :decko do
  namespace :bootstrap do
    desc "reseed, re-clean, and re-dump"
    task update: :environment do
      %w(reseed bootstrap:clean bootstrap:dump).each do |task|
        Rake::Task["decko:#{task}"].invoke
      end
    end

    desc "remove unneeded cards, acts, actions, changes, and references"
    task clean: :environment do
      Card::Cache.reset_all
      clean_cards
      clean_files
      clean_acts_and_actions
      Card::Cache.reset_all
    end

    def clean_cards
      puts "clean cards"
      # change actors so we can delete unwanted user cards that made changes
      Card::Act.update_all actor_id: Card::WagnBotID
      Card::Auth.as_bot do
        ignoramus.item_cards.each(&:delete!) if (ignoramus = Card["*ignore"])
      end
      clean_machines
      Card.empty_trash
    end


    task clean_machines: :environment do
      clean_machines
    end

    def clean_machines
      puts "clean machines"
      Card.reset_all_machines
      [[:all, :script], [:all, :style], [:script_html5shiv_printshiv]].each do |name|
        puts "coding machine output for #{Card::Name[*name]}"
        Card[*name].make_machine_output_coded
      end
    end

    def clean_files
      puts "clean files"
      Card::Cache.reset_all
      # TODO: generalize to all unnecessary files
      remove_old_machine_files
    end

    def remove_old_machine_files
      # FIXME: can this be associated with the machine module somehow?
      %w(machine_input machine_output).each do |codename|
        Card.search(right: { codename: codename }).each do |card|
          FileUtils.rm_rf File.join("files", card.id.to_s), secure: true
          card.delete!
        end
      end
    end#

    def clean_acts_and_actions
      clean_history
      clean_time_and_user_stamps
    end

    def clean_history
      puts "clean history"
      act = Card::Act.create! actor_id: Card::WagnBotID, card_id: Card::WagnBotID
      Card::Action.make_current_state_the_initial_state act
      #conn.execute("truncate card_acts")
      ActiveRecord::Base.connection.execute("truncate sessions")
    end

    def clean_time_and_user_stamps
      puts "clean time and user stamps"
      conn = ActiveRecord::Base.connection
      who_and_when = [Card::WagnBotID, Time.now.utc.to_s(:db)]
      conn.update(
          "update cards set creator_id=%1$s, created_at='%2$s', updater_id=%1$s, updated_at='%2$s'" %
              who_and_when
      )
      conn.update("update card_acts set actor_id=%s, acted_at='%s'" % who_and_when)
    end


    desc "dump db to bootstrap fixtures"
    task dump: :environment do
      Card::Cache.reset_all
      DECKO_SEED_TABLES.each do |table|
        i = "000"
        write_seed_file table do |file|
          yamlize_records table do |record, hash|
            hash["#{table}_#{i.succ!}"] = record
          end
        end
      end
    end

    def write_seed_file table
      filename = File.join DECKO_SEED_PATH, "#{table}.yml"
      File.open filename, "w" do |file|
        file.write yield
      end
    end

    def yamlize_records table
      data = ActiveRecord::Base.connection.select_all "select * from #{table}"
      YAML.dump(
          data.each_with_object({}) do |record, hash|
            record["trash"] = false if record.key? "trash"
            record["draft"] = false if record.key? "draft"
            yield record, hash
          end
      )
    end
  end

end


# desc "copy files from template database to standard mod and update cards"
# task copy_mod_files: :environment do
#   # mark mod files as mod files
#   Card::Auth.as_bot do
#     each_file_card  do |card|
#       # make card a mod file card
#       mod_name =
#         card.left&.type_id == Card::SkinID ? "bootstrap" : "standard"
#       card.update_attributes! storage_type: :coded,
#                               mod: mod_name,
#                               empty_ok: true
#     end
#   end
# # end

#def each_file_card
#  Card.search(type: %w(in Image File), ne: "").each do |card|
#    if card.coded? || card.codename == "new_file" ||
#       card.codename == "new_image"
#      puts "skipping #{card.name}: already in code"
#    else
#      puts "working on #{card.name}"
#      yield card
#    end
#  end
#end