class CardSpecLoader
  class << self
    def init
      require "spork"
      ENV["RAILS_ENV"] = "test"
      require "timecop"
    end

    def prefork
      Spork.prefork do
        require_environment
        load_shared_examples

        # Requires supporting ruby files with custom matchers and macros, etc,
        # in spec/support/ and its subdirectories.
        Dir[File.join(Cardio.gem_root, "spec/support/matchers/*.rb")].sort.each do |f|
          require f
        end
        yield if block_given?
      end
    end

    def joe_user_id
      @joe_user_id ||= "joe_user".card_id
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

        CardSpecLoader.wrap_config config
        yield config if block_given?
      end
    end

    def example_signin metadata
      Card::Auth.signin example_user_id(metadata[:with_user]) unless metadata[:as_bot]
    end

    def example_user_id with_user
      case with_user
      when String
        with_user.card_id
      when Card
        with_user.id
      when Integer
        with_user
      else
        joe_user_id
      end
    end

    def wrap_config config
      before_config config
      around_config config
      after_config config
    end

    def before_config config
      config.before do |example|
        metadata = example.metadata
        Cardio.delaying! :off
        CardSpecLoader.example_signin metadata
        CardSpecLoader.output_length metadata[:output_length]

        Card::Cache.restore
        Card::Env.reset
        Card::Env.params = metadata[:params] if metadata[:params]
      end
    end

    def output_length num
      return unless num

      RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = num
    end

    def around_config config
      config.around :example, :as_bot do |example|
        Card::Set::Self::Role.clear_rolehash
        Card::Auth.signin CardSpecLoader.joe_user_id
        Card::Auth.as_bot { example.run }
      end
    end

    def after_config config
      config.after { Timecop.return }
    end

    def helper
      require File.expand_path "card_spec_helper.rb", __dir__
      RSpec::Core::ExampleGroup.include Card::SpecHelper
      RSpec::Core::ExampleGroup.extend Card::SpecHelper::ClassMethods
      Card.include Card::SpecHelper::CardHelper
      Card.include Card::SpecHelper::SetHelper
      Card.extend Card::SpecHelper::CardHelper::ClassMethods
    end

    def load_shared_examples
      require File.expand_path "card_shared_examples", __dir__
      %w[shared_examples shared_context].each do |dirname|
        Cardio::Mod.dirs.each "spec/#{dirname}" do |shared_ex_dir|
          Dir["#{shared_ex_dir}/**/*.rb"].sort.each { |f| require f }
        end
      end
    end

    def deck_root
      root = ENV.fetch("DECK_ROOT", nil) || ENV.fetch("RAILS_ROOT", nil) || ENV.fetch("PWD", nil)
      raise StandardError, "No DECK_ROOT given. Can't load environment." unless root

      root
    end

    def require_environment
      path = File.join deck_root, "config/environment.rb"
      unless File.exist? path
        raise StandardError,
              "Cannot find config/environment.rb in #{path}." \
              "run rspec from deck root or use DECK_ROOT environmental variable."
      end
      require path
    end
  end
end
