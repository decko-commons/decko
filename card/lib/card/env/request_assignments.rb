class Card
  module Env
    # environmental variables assigned based on request
    module RequestAssignments
      private

      def assign_ajax c
        c.request.xhr? || c.request.params[:simulate_xhr]
      end

      def assign_html c
        [nil, "html"].member?(c.params[:format])
      end

      def assign_host c
        c.request.env["HTTP_HOST"]
      end

      def assign_protocol c
        c.request.protocol
      end

      def assign_origin c
        "#{protocol}#{c.request.host_with_port}"
      end
    end
  end
end
