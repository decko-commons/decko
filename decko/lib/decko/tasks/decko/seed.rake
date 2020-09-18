namespace :decko do
  namespace :seed do
    # ARDEP: this is all Rails -> AR standard usages, need alternatives in loading data to storage models
    desc "reseed, migrate, re-clean, and re-dump"
    task update: :environment do
      ENV["STAMP_MIGRATIONS"] = "true"
      ENV["GENERATE_FIXTURES"] = "true"
      %w[reseed update seed:clean seed:supplement seed:dump].each do |task|
        Rake::Task["decko:#{task}"].invoke
      end
    end

    desc "remove unneeded cards, acts, actions, changes, and references"
    task clean: :environment do
      Card::Cache.reset_all
      clean_cards
      clean_acts_and_actions
      Card::Cache.reset_all
    end

    def clean_cards
      puts "clean cards"
      # change actors so we can delete unwanted user cards that made changes
      Card::Act.update_all actor_id: Card::WagnBotID
      delete_ignored_cards
      clean_machines
      # clean_unwanted_cards
      Card.empty_trash
    end

    def clean_unwanted_cards
      Card.search(right: { codename: "all" }).each(&:delete!)
    end

    def delete_ignored_cards
      return unless (ignore = Card["*ignore"])
      Card::Auth.as_bot do
        ignore.item_cards.each(&:delete!)
      end
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

    def reseed_machine_output
      machine_seed_names.each do |name|
        puts "coding machine output for #{name}"
        Card[name].make_machine_output_coded
      end
    end

    def clean_inputs_and_outputs
      # FIXME: can this be associated with the machine module somehow?
      %w[machine_input machine_output machine_cache].each do |codename|
        Card.search(right: { codename: codename }).each do |card|
          FileUtils.rm_rf File.join("files", card.id.to_s), secure: true
          next if reserved_output? card.name
          card.delete!
        end
      end
    end

    def reserved_output? name
      (machine_seed_names.member? name.left_name.key) &&
        (name.right_name.key == :machine_output.cardname.key)
    end

    def machine_seed_names
      @machine_seed_names ||=
        [%i[all script], %i[all style], [:script_html5shiv_printshiv]].map do |name|
          Card::Name[*name]
        end
    end

    # def clean_files
    #   puts "clean files"
    #   Card::Cache.reset_all
    #   # TODO: generalize to all unnecessary files
    #   remove_old_machine_files
    # end

    def clean_acts_and_actions
      clean_history
      clean_time_and_user_stamps
    end

    def clean_history
      puts "clean history"
      act = Card::Act.create! actor_id: Card::WagnBotID, card_id: Card::WagnBotID
      Card::Action.make_current_state_the_initial_state act
      # conn.execute("truncate card_acts")
      ActiveRecord::Base.connection.execute("truncate sessions")
    end

    def clean_time_and_user_stamps
      puts "clean time and user stamps"
      conn = ActiveRecord::Base.connection
      who_and_when = [Card::WagnBotID, Time.now.utc.to_s(:db)]
      conn.update "UPDATE cards SET " \
                  "creator_id=%1$s, created_at='%2$s', " \
                  "updater_id=%1$s, updated_at='%2$s'" % who_and_when
      conn.update "UPDATE card_acts SET actor_id=%s, acted_at='%s'" % who_and_when
    end

    desc "add test data"
    task supplement: :environment do
      add_test_data
    end

    def add_test_data
      return unless Rails.env == "test"
      load CARD_TEST_SEED_SCRIPT_PATH
      SharedData.add_test_data
    end

    desc "dump db to bootstrap fixtures"
    task dump: :environment do
      Card::Cache.reset_all
      CARD_SEED_TABLES.each do |table|
        i = "000"
        write_seed_file table do
          yamlize_records table do |record, hash|
            hash["#{table}_#{i.succ!}"] = record
          end
        end
      end
    end

    def write_seed_file table
      path = Rails.env == "test" ? CARD_TEST_SEED_PATH : CARD_SEED_PATH
      filename = File.join path, "#{table}.yml"
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
#       card.update! storage_type: :coded,
#                               mod: mod_name,
#                               empty_ok: true
#     end
#   end
# # end

# def each_file_card
#   Card.search(type: %w(in Image File), ne: "").each do |card|
#     if card.coded? || card.codename == "new_file" ||
#        card.codename == "new_image"
#       puts "skipping #{card.name}: already in code"
#     else
#       puts "working on #{card.name}"
#       yield card
#     end
#   end
# end
