class Card
  class View
    module Options
      # manages showing and hiding optional view renders
      module Visibility
        # tracks show/hide value for each view with an explicit setting
        # eg  { toggle: :hide }
        def viz_hash
          @viz_hash ||= {}
        end

        # test methods

        def hide? view
          viz_hash[view&.to_sym] == :hide
        end

        def show? view
          !hide? view
        end

        # write methods

        def show *views
          viz views, :show
        end

        def hide *views
          viz views, :hide
        end

        # force write methods

        def show! *views
          viz views, :show, true
        end

        def hide! *views
          viz views, :hide, true
        end

        # advanced write method
        VIZ_SETTING = { show: :show, true => :show,
                        hide: :hide, false => :hide, nil => :hide }.freeze

        def viz views, setting, force=false
          Array.wrap(views).flatten.each do |view|
            view = view.to_sym
            next if !force && viz_hash[view]

            viz_hash[view] = VIZ_SETTING[setting]
          end
        end

        def visible? view
          viz view, yield unless viz_hash[view]
          show? view
        end

        # test whether view is optional
        # (@optional is set in normalize_options
        # @return [true/false]
        def optional?
          @optional
        end

        # translate raw hide, show options (which can be strings, symbols,
        # arrays, etc)
        def process_visibility
          viz_hash.reverse_merge! parent.viz_hash if parent
          process_visibility_options live_options
          viz requested_view, @optional if @optional && !viz_hash[requested_view]
        end

        private

        # if true, #process returns nil
        def hide_requested_view?
          optional? && hide?(requested_view)
        end

        # takes an options_hash and processes it to update viz_hash
        def process_visibility_options options_hash
          %i[hide show].each do |setting|
            views = View.normalize_list(options_hash.delete(setting)).map(&:to_sym)
            viz views, setting, true
          end
        end

        def normalized_visibility_options
          viz_hash.each_with_object({}) do |(key, val), hash|
            hash[val] ||= []
            hash[val] << key
          end
        end
      end
    end
  end
end
