class CardSpecLoader
  class << self
    def init
      require "spork"
      ENV["RAILS_ENV"] = "test"
      require "timecop"
    end

    def prefork
      Spork.prefork do
        unless ENV["RAILS_ROOT"]
          raise Card::Error, "No RAILS_ROOT given. Can't load environment."
        end
        require File.join ENV["RAILS_ROOT"], "config/environment"
        load_shared_examples
        require File.expand_path("../simplecov_helper.rb", __FILE__)
        require File.expand_path("../../../db/test_seed.rb", __FILE__)

        # Requires supporting ruby files with custom matchers and macros, etc,
        # in spec/support/ and its subdirectories.
        Dir[File.join(Cardio.gem_root, "spec/support/matchers/*.rb")].each do |f|
          require f
        end
        yield if block_given?
      end
    end

    def each_run
      # This code will be run each time you run your specs.
      yield if block_given?
    end

    def rspec_config
      require "rspec/rails"

      @@joe_user_id = Card["joe_user"].id
      RSpec.configure do |config|
        config.include RSpec::Rails::Matchers::RoutingMatchers,
                       file_path: %r{\bspec/controllers/}
        config.include RSpecHtmlMatchers
        # format_index = ARGV.find_index {|arg| arg =~ /--format|-f/ }
        # formatter = format_index ? ARGV[ format_index + 1 ] : 'documentation'
        # config.default_formatter=formatter

        config.infer_spec_type_from_file_location!
        # config.include CustomMatchers
        # config.include ControllerMacros, type: :controllers

        # == Mock Framework
        # If you prefer to mock with mocha, flexmock or RR,
        # uncomment the appropriate symbol:
        # :mocha, :flexmock, :rr

        config.use_transactional_fixtures = true
        config.use_instantiated_fixtures = false

        config.before(:each) do |example|
          Cardio.delaying! :off
          unless example.metadata[:as_bot]
            user_id =
              case example.metadata[:with_user]
              when String
                Card.fetch_id example.metadata[:with_user]
              when Card
                Card.id
              when Integer
                example.metadata[:with_user]
              else
                @@joe_user_id
              end
            Card::Auth.signin user_id
          end

          if example.metadata[:output_length]
            RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length =
              example.metadata[:output_length]
          end
          Card::Cache.restore
          Card::Env.reset
          Card::Env[:params] = example.metadata[:params] if example.metadata[:params]
        end

        config.around(:example, :as_bot) do |example|
          Card::Auth.signin @@joe_user_id
          Card::Auth.as_bot do
            example.run
          end
        end

        config.after(:each) do
          Timecop.return
        end
        yield config if block_given?
      end
    end

    def helper
      require File.expand_path "../card_spec_helper.rb", __FILE__
      RSpec::Core::ExampleGroup.send :include, Card::SpecHelper
      RSpec::Core::ExampleGroup.send :extend, Card::SpecHelper::ClassMethods
      Card.send :include, Card::SpecHelper::CardHelper
      Card.send :include, Card::SpecHelper::SetHelper
      Card.send :extend, Card::SpecHelper::CardHelper::ClassMethods
    end

    def load_shared_examples
      require File.expand_path "../card_shared_examples", __FILE__
      %w[shared_examples shared_context].each do |dirname|
        Cardio::Mod.dirs.each "spec/#{dirname}" do |shared_ex_dir|
          Dir["#{shared_ex_dir}/**/*.rb"].sort.each { |f| require f }
        end
      end
    end
  end
end
