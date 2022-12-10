class Card
  module Model
    module SaveHelper
      # private helper methods for public SaveHelper api
      module SaveArguments
        private

        # @return args
        def standardize_args name_or_args, content_or_args=nil, _ignore=nil
          if name_or_args.is_a?(Hash)
            name_or_args
          else
            add_name name_or_args, content_or_args || {}
          end
        end

        def standardize_update_args name_or_args, content_or_args
          return name_or_args if name_or_args.is_a?(Hash)

          hashify content_or_args, :content
        end

        def hashify value_or_hash, key
          if value_or_hash.is_a?(Hash)
            value_or_hash
          elsif value_or_hash.nil?
            {}
          else
            { key => value_or_hash }
          end
        end

        def create_args name_or_args, content_or_args=nil
          args = standardize_args name_or_args, content_or_args
          resolve_name_conflict args
          args
        end

        def name_from_args name_or_args
          name_or_args.is_a?(Hash) ? name_or_args[:name] : name_or_args
        end

        def resolve_name_conflict args
          rename = args.delete :rename_if_conflict
          return unless args[:name] && rename

          args[:name] = Card.uniquify_name args[:name], rename
        end
      end
    end
  end
end
