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

    def joe_user_id
      @joe_user_id ||= Card.fetch_id "joe_user"
    end

    def rspec_config
      require "rspec/rails"

      RSpec.configure do |config|
        config.include RSpec::Rails::Matchers::RoutingMatchers,
                       file_path: %r{\bspec/controllers/}
        config.include RSpecHtmlMatchers
        # format_index = ARGV.find_index {|arg| arg =~ /--format|-f/ }
        # formatter = format_index ? ARGV[ format_index + 1 ] : 'documentation'
        # config.default_formatter=formatter

        config.infer_spec_type_from_file_location!
        config.use_transactional_fixtures = true
        config.use_instantiated_fixtures = false

        before_config config
        around_config config
        after_config config
        yield config if block_given?
      end
    end

    def example_signin metadata
      Card::Auth.signin example_user_id(metadata[:user_id]) unless metadata[:as_bot]
    end

    def example_user_id with_user
      case with_user
      when String
        Card.fetch_id with_user
      when Card
        with_user.id
      when Integer
        with_user
      else
        joe_user_id
      end
    end

    def before_config config
      config.before(:each) { |example| before_example example.metadata }
    end

    def before_example metadata
      Cardio.delaying! :off
      example_signin metadata
      output_length metadata[:output_length]

      Card::Cache.restore
      Card::Env.reset
      Card::Env[:params] = metadata[:params] if metadata[:params]
    end

    def output_length num
      return unless num

      RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = num
    end

    def around_config config
      config.around :example, :as_bot do |example|
        Card::Auth.signin joe_user_id
        Card::Auth.as_bot { example.run }
      end
    end

    def after_config config
      config.after(:each) { Timecop.return }
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
