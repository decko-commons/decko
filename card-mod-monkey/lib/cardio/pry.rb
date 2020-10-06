module Cardio
  # These commands are available in the console when using binding.pry for breakpoints.
  module Pry
    require "rails/console/app"
    include Rails::ConsoleMethods
    include Commands

    def create name="test card", content="some content", type="basic"
      if name.is_a? Hash
        Card.create! name
      elsif content.is_a? Hash
        Card.create! content.merge(name: name)
      else
        Card.create! name: name, content: content, type: type
      end
    end

    def update name="test card", *args
      card_attr = {}
      if args.first.is_a? String
        card_attr[:content] = args.shift
        card_attr.merge!(args.first)
      else
        card_attr = args.first
      end
      Card.fetch(name).update_attributes card_attr
    end

    # Shortcut for fetching cards. You can continue to work with the
    # last fetched card by calling `fe` without arguments.
    # If the first call of `fe` is without argument, fe points to the card "Home"
    # Example:
    #    fe.name    # => "Home"
    #    fe "Basic"
    #    fe.name    # => "Basic"
    #    fe.type    # => "cardtype"
    def fe name=nil
      if name
        @fe = Card.fetch name
      else
        @fe ||= Card.fetch "home"
      end
    end

    def cr name=nil, content="some content", type="basic"
      if name
        @cr = create name, content, type
      else
        @cr ||= create
      end
    end

    def ab
      Card::Auth.as_bot
    end

    # use syntax highlighting if html is detected
    def puts *args
      text = args.first
      return super unless args.size == 1 && htmlish?(text)
      html = Nokogiri::XML text, &:noblanks
      puts_html(html, text) { |*super_args| super(*super_args) }
    end

    def htmlish? text
      text.is_a?(String) && (text.match?(%r{</\w+>}) || text.include?("\e"))
    end

    def puts_html html, text, &block
      if html.errors.present?
        puts_html_errors html, text, &block
      else
        puts_highlighted_html html, &block
      end
    end

    def puts_html_errors html, text
      yield text
      puts
      yield "WARNING: detected invalid html".red
      yield html.errors
    end

    def puts_highlighted_html html
      # yield "with syntax highlighting:\n"
      yield CodeRay.scan(html.root.to_s, :html).term
    end

    def hputs text
      text = Nokogiri::XML(text, &:noblanks).root.to_s
      print CodeRay.scan(text, :html).term
      print "\n"
    end

    def _a
      @_array ||= (1..6).to_a
    end

    def _h
      @_hash ||= { hello: "world", free: "of charge" }
    end

    def _u
      @_user ||= Card.fetch "Joe User"
    end

    intro = File.read File.expand_path("../pry/intro.txt", __FILE__)
    puts intro
  end
end
