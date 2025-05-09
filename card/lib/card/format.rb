# -*- encoding : utf-8 -*-

class Card
  # Card::Format and its subclasses ({Card::Format::HtmlFormat},
  # {Card::Format::JsonFormat}, {Card::Format::XmlFormat}, etc)
  # are responsible for defining and rendering _views_.
  #
  # However, monkeys (those who code in the Card/Decko framework) rarely write code
  # directly in these classes. Instead they organize their code using {Cardio::Mod mods}.
  #
  # {Cardio::Mod} explains how to set up a mod.
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
    include Wrapper
    include ContextNames
    include Content
    include Error
    include MethodDelegation

    cattr_accessor :registered, :aliases
    self.registered = []
    self.aliases = {}

    attr_reader :card, :parent, :main_opts, :modal_opts
    attr_accessor :form, :error_status, :rendered

    delegate :basket, to: Set
    delegate :session, :params, to: Env

    @symbol = :base

    class << self
      attr_writer :symbol

      def view_caching?
        true
      end
    end

    def initialize card, opts={}
      @card = card
      require_card_to_initialize!
      opts.each { |key, value| instance_variable_set "@#{key}", value }
      include_set_format_modules
    end

    def require_card_to_initialize!
      return if @card

      raise Card::Error, ::I18n.t(:lib_exception_init_without_card)
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

    def controller
      @controller || Env.controller ||= CardController.new
    end

    def request_url
      controller.request&.original_url || path
    end

    def mime_type
      "text/plain"
    end

    def escape_literal literal
      literal
    end

    def symbol
      self.class.symbol
    end
    alias_method :to_sym, :symbol
  end
end
