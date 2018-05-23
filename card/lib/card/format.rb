# -*- encoding : utf-8 -*-

class Card
  # _Views_ are the primary way users interact with cards. Card::Format and its subclasses ({Card::Format::HtmlFormat}, {Card::Format::JsonFormat}, {Card::Format::XmlFormat}, etc) are responsible for defining and rendering _views_.
  #
  # However, Deck-coders (those who code in the Card/Decko framework) rarely write code directly in these classes. Instead they organize their code using {Card::Mods mods}. The {Card::Mod} docs explain how to set up a mod. Once you've done that, you're ready to define a view.  These docs will introduce the basics of view definition and
  #
  # Here is a very simple view that just defines a label for the card – its name:
  #
  #     view :label do
  #       card.name
  #     end
  #
  # If a format is not specified, the view is defined on the base format class, Card::Format. The following two definitions are equivalent to the definition above:
  #
  #     format do
  #       view(:label) { card.name }
  #     end
  #
  #     format(:base) { view(:label) { card.name } }
  #
  # But suppose you would like this view to appear differently in different output formats. For example, you'd like this label to have a tag with a class attribute HTML so that you can style it with CSS.
  #
  #     format :html do
  #       view :label do
  #         div(class: "my-label") { card.name }
  #       end
  #     end
  #
  # Note that in place of card.name, you could also use `super`, because this view is translated into a method on Card::Format::HtmlFormat, which inherits from Card::Format.
  #
  # ## Common arguments for view definitions
  #
  # * :perms - restricts view permissions. Value can be :create, :read, :update, :delete, or a Proc.
  # * :tags - tag view as needed.
  #
  # The most commmon tag is "unknown_ok," which indicates that a view can be rendered even if the card is "unknown" (not real or virtual).
  #
  # ## Rendering views
  #
  # To render our label view, you can use either of these:
  #
  #     render :label
  #     render_label
  #
  class Format
    include Card::Env::Location
    include Nesting
    include Permission
    include Render
    include ContextNames
    include Content
    include Error
    include MethodDelegation

    extend Registration

    cattr_accessor :registered
    self.registered = []
    VIEW_VARS = [ :perms, :denial, :closed, :error_code ]
    (VIEW_VARS + [ :view_tags, :aliases ]).each do |accessor_name|
      cattr_accessor accessor_name
      send "#{accessor_name}=", {}
    end

    attr_reader :card, :parent, :main_opts
    attr_accessor :form, :error_status

    def self.view_caching?
      true
    end

    def initialize card, opts={}
      @card = card
      require_card_to_initialize!
      opts.each { |key, value| instance_variable_set "@#{key}", value }
      include_set_format_modules
      self
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
        t = ActionView::Base.new c.class.view_paths, { _routes: c._routes }, c
        t.extend c.class._helpers
        t
      end
    end

    def tagged view, tag
      self.class.tagged view, tag
    end

    def mime_type
      "text/text"
    end

    def to_sym
      Card::Format.format_sym self
    end
  end
end
