require_dependency 'card/dirty'

class Card
  module Set
    # advanced set module API
    module AdvancedApi
      def ensure_set &block
        set_module = yield
        set_module = card_set_module_const_get(set_module) unless set_module.is_a?(Module)
        set_module
      rescue NameError => e
        if e.message =~ /uninitialized constant (?:Card::Set::)?(.+)$/
          define_set Regexp.last_match(1)
        end
        # try again - there might be another submodule that doesn't exist
        ensure_set(&block)
      else
        set_module.extend Card::Set
      end

      def attachment name, args
        include_set Abstract::Attachment
        add_attributes name, "remote_#{name}_url".to_sym,
                       :action_id_of_cached_upload, :empty_ok,
                       :storage_type, :bucket, :mod
        uploader_class = args[:uploader] || ::CarrierWave::FileCardUploader
        mount_uploader name, uploader_class
        Card.define_dirty_methods name
      end

      def stage_method method, opts={}, &block
        class_eval do
          define_method "_#{method}", &block
          define_method method do |*args|
            if (error = wrong_stage(opts) || wrong_action(opts[:on]))
              raise Card::Error, error
            end

            send "_#{method}", *args
          end
        end
      end

      private

      # @param set_name [String] name of the constant to be defined
      def define_set set_name, start_const=Card::Set
        constant_pieces = set_name.split("::")
        constant_pieces.inject(start_const) do |set_mod, module_name|
          set_mod.const_get_or_set module_name do
            Module.new
          end
        end
      end

      # "set" is the noun not the verb
      def card_set_module_const_get const
        Card::Set.const_get normalize_const(const)
      end

      def normalize_const const
        case const
        when Array
          const.map { |piece| piece.to_s.camelcase }.join("::")
        when Symbol
          const.to_s.camelcase
        else
          const
        end
      end
    end
  end
end
