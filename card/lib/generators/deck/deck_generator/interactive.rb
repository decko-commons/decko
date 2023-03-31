module Decko
  module Generators
    module Deck
      class DeckGenerator
        # Guides through the decko deck installation with an interactive menu
        # Offers the possibilitiy to
        #  - edit database config
        #  - edit application.rb
        #  - seed database
        #  - run server
        class Interactive
          def initialize destination_root, dev=false
            @dev = dev
            @destination_root = destination_root
          end

          def run
            require config_path("application") # need this for Rails.env
            @menu = ActiveSupport::OrderedHash.new
            add_config_options
            add_seed_options
            add_exit_option
            while (answer = ask(build_menu)) != "x"
              if @menu.key? answer
                @menu[answer][:code].call
              else
                puts "invalid choice"
              end
            end
          end

          private

          def dev_options?
            @dev
          end

          def config_path file
            File.join destination_root, "config", file
          end

          def bundle_exec command, opts={}
            rails_env = "RAILS_ENV=#{opts[:rails_env]}" if opts[:rails_env]
            system "cd #{destination_root} && #{rails_env} bundle exec #{command}"
          end

          def build_menu
            lines = ["What would you like to do next?"]
            lines += @menu.map { |key, v|  build_option key, v[:desc], v[:command] }
            lines << "[#{@menu.keys.join}]"
            "\n#{lines.join("\n")}\n"
          end

          def build_option key, desc, command
            command &&= "#{' ' * (65 - desc.size)}[#{command}]"
            "  #{key} - #{desc}#{command}"
          end

          def add_config_options
            @menu["d"] = {
              desc: "edit database configuration file",
              command: "nano config/database.yml",
              code: proc { system "nano #{config_path 'database.yml'}" }
            }
            @menu["c"] = {
              desc: "configure Decko (e.g. email settings)",
              command: "nano config/application.rb",
              code: proc { system "nano #{config_path 'application.rb'}" }
            }
          end

          def add_seed_options
            add_common_seed_option
            add_seed_all_option
          end

          def add_common_seed_option
            @menu["s"] = {
              desc: "seed #{Rails.env}#{' and test' if dev_options?} database",
              command: "decko setup",
              code: proc do
                bundle_exec "rake decko:seed"
                bundle_exec "rake decko:seed", rails_env: "test" if dev_options?
                add_after_seed_options
              end
            }
          end

          def add_seed_all_option
            @menu["a"] = {
              desc: "seed all databases (production, development, and test)",
              command: "decko setup --all",
              code: proc do
                %w[production development test].each do |env|
                  bundle_exec "rake decko:seed", rails_env: env
                end
                add_after_seed_options
              end
            }
          end

          def add_exit_option
            @menu["x"] = {
              desc: "exit (run 'decko setup' to complete the installation later)"
            }
          end

          def add_after_seed_options
            @menu["x"][:desc] = "exit"
            @menu["r"] = {
              desc: "run decko server",
              command: "decko server",
              code: proc { bundle_exec "decko server" }
            }
          end
        end
      end
    end
  end
end
