module Cardio
  class Commands
    module ClassMethods
      def run_non_deck_command command, commands_script
        if command == "new"
          ARGV.shift
          Cardio::Generators::Deck::DeckGenerator.start
        elsif command.blank?
          require commands_script
        else
          puts "ERROR: `#{ScriptLoader.script_name} #{command}` "\
               "cannot be run from outside deck".red
        end
      end
    end
  end
end