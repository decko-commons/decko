# -*- encoding : utf-8 -*-

class Card
  # Card::Format and its subclasses ({Card::Format::HtmlFormat},
  # {Card::Format::JsonFormat}, {Card::Format::XmlFormat}, etc)
  # are responsible for defining and rendering _views_.
  #
  # However, monkeys (those who code in the Card/Decko framework) rarely write code
  # directly in these classes. Instead they organize their code using {Card::Mod mods}.
  #
  # {Card::Mod} explains how to set up a mod.
  # {Card::Set::Format} explains how to use this and other format classes within a mod.
  # {Card::Set::Format::AbstractFormat} introduces the view API, which is organized with
  # these format classes.
  #
  class Format
    extend ActiveSupport::Autoload
    extend Registration

    include Card::Env::Location
    include Nesting
    include Render
    include ContextNames
    include Content
    include Error
    include MethodDelegation

    cattr_accessor :registered, :aliases
    self.registered = []
    self.aliases = {}

    attr_reader :card, :parent, :main_opts, :modal_opts
    attr_accessor :form, :error_status, :rendered

    def self.view_caching?
      true
    end

    def initialize card, opts={}
      @card = card
      require_card_to_initialize!
      opts.each { |key, value| instance_variable_set "@#{key}", value }
      include_set_format_modules
    end

    def require_card_to_initialize!
      return if @card

      msg = I18n.t :exception_init_without_card, scope: "lib.card.format"
      raise Card::Error, msg
    end

    def include_set_format_modules
      self.class.format_ancestry.reverse_each do |klass|
        card.set_format_modules(klass).each do |m|
          singleton_class.send :include, m
        end
      end
    end

    def page controller, view, slot_opts
      @controller = controller
      context_names # loads names and removes #name_context from slot_opts
      @card.run_callbacks :show_page do
        show view, slot_opts
      end
    end

    def params
      Env.params
    end

    def controller
      @controller || Env[:controller] ||= CardController.new
    end

    def session
      Env.session
    end

    def template
      @template ||= begin
        c = controller
        lookup_context = ActionView::LookupContext.new c.class.view_paths
        t = ActionView::Base.new(
          lookup_context, { _routes: c._routes }, c
        )
        t.extend c.class._helpers
        t
      end
    end

    def mime_type
      "text/plain"
    end

    def escape_literal literal
      literal
    end

    def to_sym
      Card::Format.format_sym self
    end
  end
end
