%w[helper matchers].each do |load_dir|
  load_path = File.expand_path "../#{load_dir}/*.rb", __FILE__
  Dir[load_path].each { |f| require f }
end


class Card
  # to be included in  RSpec::Core::ExampleGroup
  module SpecHelper
    include ViewHelper
    include EventHelper
    include SaveHelper

    # ~~~~~~~~~  HELPER METHODS ~~~~~~~~~~~~~~~#
    include Rails::Dom::Testing::Assertions::SelectorAssertions

    def login_as user
      Card::Auth.current_id = (uc = Card[user.to_s]) && uc.id
      return unless @request
      @request.session[:user] = Card::Auth.current_id
      # warn "(ath)login_as #{user.inspect}, #{Card::Auth.current_id}, "\
      #      "#{@request.session[:user]}"
    end

    def card_subject
      Card["A"].with_set(described_class)
    end

    def format_subject format=:html
      card_subject.format_with_set(described_class, format)
    end

    def expect_content
      expect(card_subject.content)
    end

    def assert_view_select view_html, *args, &block
      node = Nokogiri::HTML::Document.parse(view_html).root
      if block_given?
        assert_select node, *args, &block
      else
        assert_select node, *args
      end
    end

    def debug_assert_view_select view_html, *args, &block
      log_html view_html
      assert_view_select view_html, *args, &block
    end

    def log_html html
      parsed = CodeRay.scan(Nokogiri::XML(html, &:noblanks).to_s, :html)
      if Rails.logger.respond_to? :rspec
        Rails.logger.rspec "#{parsed.div}#{CODE_RAY_STYLE}"
      else
        puts parsed.text
      end
    end

    CODE_RAY_STYLE = <<-HTML
      <style>
        .CodeRay {
          background-color: #FFF;
          border: 1px solid #CCC;
          padding: 1em 0px 1em 1em;
        }
        .CodeRay .code pre { overflow: auto }
      </style>
    HTML

    def users
      SharedData::USERS.sort
    end

    def bucket_credentials key
      @buckets ||= bucket_credentials_from_yml_file || {}
      @buckets[key]
    end

    def bucket_credentials_from_yml_file
      yml_file = ENV["BUCKET_CREDENTIALS_PATH"] ||
                 File.expand_path("../bucket_credentials.yml", __FILE__)
      File.exist?(yml_file) && YAML.load_file(yml_file).deep_symbolize_keys
    end

    def with_rss_enabled
      Card.config.rss_enabled = true
      yield
    ensure
      Card.config.rss_enabled = false
    end
  end
end
