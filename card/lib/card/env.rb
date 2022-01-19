class Card
  # Card::Env is a module for containing the variable details of the environment
  # in which Card operates.
  #
  # Env can differ for each request; Card.config should not.
  module Env
    extend LocationHistory
    extend SlotOptions
    extend Support
    extend Serializable
    extend Serialization

    class << self
      attr_accessor :controller
      attr_writer :session, :main_name, :params

      def request
        controller&.request
      end

      def session
        @session ||= request&.session || {}
      end

      def reset controller=nil
        @controller = controller
        @params = controller&.params || {}
        @session = @success = @serialized = @slot_opts = nil
      end

      def success cardname=nil
        @success ||= Env::Success.new(cardname, params[:success])
      end

      def localhost?
        host&.match?(/^localhost/)
      end
    end
  end
end

Card::Env.reset
