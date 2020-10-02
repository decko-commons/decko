# -*- encoding : utf-8 -*-

require 'rails'
require 'card/config/initializers/sedate_parser'
require 'cardio/application_record'

Bundler.require :default, *Rails.groups

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(assets: %w[development test cypress])
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Cardio
  class Application < Rails::Application
    class << self

      def inherited base
warn "ib Card #{base}, Ins:#{base.instance} CF:#{base.called_from}" #{caller*"\n"}"
        super
        # The second test shouldn't be true unless someone else set it, but
        # not to the ./config/application.rb defined application class
#warn " set? app in cardappl to si:#{self.instance} s:#{self} b:#{base} bi:#{base.instance} b:#{base} c/nl:#{Cardio.application} T:#{base.instance.is_a?(self.class)} 2:#{base.is_a?(self.class)} 3:#{self.instance.is_a?(base)}"
warn "CARD #{__LINE__} roots #{self.instance.config.gem_root} #{Cardio.gem_root}"
        add_lib_to_load_path!(find_root(base.called_from))
        if self.instance.config.gem_root == Cardio.gem_root
          Cardio.application = self.instance
          Rails.app_class = self
warn "CARD #{__LINE__} in card_appl #{self.instance.config.gem_root} 1st #{self} bi:#{base.instance} b:#{base} c/nl:#{Cardio.application}"
warn "seting cardio app #{self}"
          # connect actual app instance to Cardio mattr
warn "seting cardio app i:#{self.instance}"
          Cardio.load_card_environment
#warn "early c on load card "
          #Cardio.connect_on_load
        end
      end
    end

    initializer :card_load_config_initializers,
                after: :load_config_initializers do
warn "CARD: initting #{Cardio.config.paths} #{Cardio.config.paths["config/initializers"].existent.map(&:to_s)*", "}"
      Cardio.config.paths["config/initializers"].existent.sort.each do |initializer|
warn "load cf inits: #{initializer}"
        load(initializer)
      end
    end

    initializer :connect_on_load do
warn "c on load card "
      Cardio.connect_on_load self
    end

    def config
      return @config unless @config.nil?
      @config = super
      @config.gem_root = Cardio.gem_root
      @config
    end
  end
end
