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
    include JsonHelper
    include FileHelper

    # ~~~~~~~~~  HELPER METHODS ~~~~~~~~~~~~~~~#
    include Rails::Dom::Testing::Assertions::SelectorAssertions

    def login_as user
      Card::Auth.signin user
      return unless @request
      Card::Env.session[Card::Auth.session_user_key] = Card::Auth.current_id
      @request.session[Card::Auth.session_user_key] = Card::Auth.current_id
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

    def sample_voo
      Card::View.new Card["A"].format, :core
    end

    def sample_pointer
      Card["u1+*roles"]
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
      SharedData::USERS.sort
    end

    def with_rss_enabled
      Cardio.config.rss_enabled = true
      yield
    ensure
      Cardio.config.rss_enabled = false
    end

    module ClassMethods
      def check_views_for_errors *views
        include_context_for views.flatten, "view without errors"
      end

      def check_format_for_view_errors format_module
        check_views_for_errors(*views(format_module))
      end

      def check_html_views_for_errors
        html_format_class = described_class.const_get("HtmlFormat")
        html_views = views html_format_class
        include_context_for html_views, "view without errors"
        include_context_for html_views, "view with valid html"
      end

      def include_context_for views, context
        views.each do |view|
          include_context context, view
        end
      end

      def views format_module
        Card::Set::Format::AbstractFormat::ViewDefinition.views[format_module].keys
      end
    end
  end
end
