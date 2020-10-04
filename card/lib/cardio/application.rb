# -*- encoding : utf-8 -*-

require 'rails'
require 'card/config/initializers/sedate_parser'
require 'cardio/application_record'

Bundler.require :default, *Rails.groups if defined?(Bundler)

module Cardio
  class Application < Rails::Application

    def configure &block
warn "DECKO configure #{block_given?}"
      super do
#warn "CONFIGC1 #{__LINE__} #{app} #{app.config} bg? #{block_given?} in configure CARDIO #{self}"
        instance_eval &block if block_given?
#warn "CONFIGC2 #{__LINE__} #{config} bg? #{block_given?}"
        # connect actual app instance to Cardio mattr
#warn "PATHSC4 #{paths} #{__LINE__} #{config} #{config.paths}"
warn "CARDAPP5 #{__LINE__} done configure"
      end
    end

    class << self
      def inherited base
warn "CARDAPP1.6 #{__LINE__} B:#{base}, B.Ins:#{base.instance} CF:#{base.called_from}" #{caller*"\n"}"
        super

warn "CARDAPP2.7 #{__LINE__} seting cardio app i:#{base.instance}"
        Rails.app_class = base
        Cardio.application= base.instance
warn "CARDAPP3.8 inherited #{base}, #{base.instance}"
        add_lib_to_load_path!(find_root(base.called_from))
      end
    end

    initializer :card_load_config,
                before: :load_environment_config do
warn "CARDAPP3: #{__LINE__} load_card_environment Cdi.app #{config} cfg:#{Cardio.config} RC:#{Rails.app_class}"
      Cardio.load_card_environment
    end

    initializer :card_load_config_initializers,
                after: :load_environment_config do
warn "CARDAPPa1.9: initting #{paths} #{paths["config/initializers"].existent&.length}"
      Cardio.load_rails_environment
warn "CONFIGCa.3.11: (SKIP?) #{__LINE__} #{config}"
        paths["config/initializers"].existent.sort.each do |initializer|
warn "a.4 12 load cf inits: #{initializer}"
          load(initializer)
        end
warn "CONFIGCa.6: #{__LINE__} #{config}"
      Cardio.connect_on_load
warn "CONFIGCa.5: #{__LINE__} #{config}"
    end

    initializer :card_connect_on_load, after: :application_record do
warn "CARDAPPa.4.12 #{__LINE__} c on load card "
      #Cardio.connect_on_load
    end
  end
end
