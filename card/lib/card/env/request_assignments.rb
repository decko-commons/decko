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
        Cardio.config.override_host || c.request.env["HTTP_HOST"]
      end

      def assign_protocol c
        Cardio.config.override_protocol || c.request.protocol
      end
    end
  end
end
