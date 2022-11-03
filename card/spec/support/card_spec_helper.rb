require "coderay"

%w[helper matchers].each do |load_dir|
  load_path = File.expand_path "../#{load_dir}/*.rb", __FILE__
  Dir[load_path].sort.each { |f| require f }
end

Cardio::Mod.dirs.each "spec/support" do |support_dir|
  Dir["#{support_dir}/**/*.rb"].sort.each { |f| require f }
end

class Card
  # to be included in  RSpec::Core::ExampleGroup
  module SpecHelper
    include ViewHelper
    include EventHelper
    include SaveHelper
    include JsonHelper
    include FileHelper

    # ~~~~~~~~~  HELPER METHODS ~~~~~~~~~~~~~~~#
    include Rails::Dom::Testing::Assertions::SelectorAssertions

    USERS = [
      "Joe Admin", "Joe User", "Joe Camel", "Sample User", "No count",
      "u1", "u2", "u3",
      "Big Brother", "Optic fan", "Sunglasses fan", "Narcissist"
    ].freeze

    def login_as user
      Env.session = @request&.session
      Auth.signin user
    end

    def card_subject
      if described_class.pattern_code == :self
        described_class.set_name_parts[3].underscore.to_sym.card
      else
        card_subject_name.card.with_set described_class
      end
    end

    def card_subject_name
      "A"
    end

    def format_subject format=:html, &block
      card_subject.format_with_set described_class, format, &block
    end

    def expect_content
      expect(card_subject.content)
    end

    def sample_voo
      Card::View.new Card["A"].format, :core
    end

    def sample_pointer
      Card["r1+*members"]
      # items: r1, r2, r3
    end

    def sample_search
      Card.fetch "Books+*type+by name"
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
    HTML

    def users
      USERS.sort
    end

    def with_rss_enabled
      Card.config.rss_enabled = true
      yield
    ensure
      Card.config.rss_enabled = false
    end

    module ClassMethods
      def check_views_for_errors format: :html, views: nil
        views ||= views format
        views = Array.wrap views
        include_context_for views, "view without errors", format
      end

      def include_context_for views, context, format=:html
        views.each do |view|
          include_context context, view, format
        end
      end

      def views format_sym
        described_class
          .format_modules(format_sym, test: false).map do |format_module|
            views_for_module format_module
          end.flatten
      end

      def views_for_module format_module
        Card::Set::Format::AbstractFormat::ViewDefinition.views[format_module].keys
      end
    end
  end
end
