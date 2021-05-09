module Patches
  module Kaminari
    module Helpers
      module Tag
        def self.included klass
          klass.class_eval do
            remove_method :page_url_for
          end
        end

        def page_url_for page
          p = params_for(page)
          p.delete :controller
          p.delete :action
          mark = p.delete("mark") || p.delete("name")
          Card.fetch(mark).format.path p
        end

        private

        def params_for page
          page_params = Rack::Utils.parse_nested_query "#{@param_name}=#{page}"
          page_params = @params.with_indifferent_access.deep_merge(page_params)

          if ::Kaminari.config.respond_to?(:params_on_first_page) &&
             !::Kaminari.config.params_on_first_page && page <= 1
            # This converts a hash:
            #   from: {other: "params", page: 1}
            #     to: {other: "params", page: nil}
            #   (when @param_name == "page")
            #
            #   from: {other: "params", user: {name: "yuki", page: 1}}
            #     to: {other: "params", user: {name: "yuki", page: nil}}
            #   (when @param_name == "user[page]")
            @param_name.to_s.scan(/\w+/)[0..-2]
                       .inject(page_params) { |h, k| h[k] }[Regexp.last_match(0)] = nil
          end

          page_params
        end
      end
    end
  end
end
