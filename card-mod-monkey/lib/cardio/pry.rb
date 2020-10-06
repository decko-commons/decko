module Cardio
  # These commands are available in the console when using binding.pry for breakpoints.
  module Pry
    require 'rails/console/app'
    include Rails::ConsoleMethods
    include Commands

    def create name='test card', content='some content', type='basic'
      if name.kind_of? Hash
        Card.create! name
      elsif content.kind_of? Hash
        Card.create!(content.merge(:name=>name))
      else
        Card.create! :name=>name, :content=>content, :type=>type
      end
    end

    def update name='test card', *args
      card_attr = {}
      if args.first.kind_of? String
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
    def fe(name = nil)
      if name
        @fe = Card.fetch name
      else
        @fe ||= Card.fetch "home"
      end
    end

    def cr(name = nil, content = 'some content', type = 'basic')
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
      return super unless args.size == 1
      text = args.first
      return super if !text.is_a?(String) || !(text =~ %r{</\w+>}) || text.include?("\e")
      html = Nokogiri::XML(text, &:noblanks)
      if html.errors.present?
        super text
        puts
        super "WARNING: detected invalid html".red
        super html.errors
      else
        super "with syntax highlighting:\n"
        super CodeRay.scan(html.root.to_s, :html).term
      end
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
      @_hash ||= {hello: "world", free: "of charge"}
    end

    def _u
      @_user ||= Card.fetch 'Joe User'
    end

    puts %{
== Command history ==
h     : hist -T 20 Last 20 commands
hg    : hist -T 20 -G Up to 20 commands matching expression
hG    : hist -G Commands matching expression ever used
hr    : hist -r hist -r <command number> to run a command
Hit Enter to repeat last command
== Variables ==
_u : Card 'Joe User'
_a : [1, 2, 3, 4, 5, 6]
_h : { hello: "world", free: "of charge" }
== Card commands ==
create : Card.create :name=>$1, :content=>($2||'some content'), :type=>($3||'basic')
update : Card.update :name=>$1, :content=>($2||'some content'), :type=>($3||'basic')
ab     : Card::Auth.as_bot
cr     : create card and assign it to cr (default: name=>'test card', content=>'some content', type=>'basic')
fe     : fetch card and assign it to fe (default: 'Home')
== Breakpoints ==
breakview (bv) : set break point where view is rendered (takes a view name and a card mark as optional argument)
breaknest (bn) : set break point where nest is rendered (takes a card mark as optional argument)
clear          : remove all break points
== Helpful debugger shortcuts ==
hputs : puts with html syntax highlighting
n     : next
s     : step
c     : continue
f     : finish
try   : execute current line (without stepping forward)
}
  end
end