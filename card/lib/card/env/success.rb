class Card
  module Env
    # Success objects
    class Success
      include Location
      include Target

      attr_accessor :name, :name_context, :reload
      attr_writer :params, :redirect, :card
      attr_reader :id

      def initialize name_context=nil, success_args=nil
        @name_context = name_context
        @new_args = {}
        @params = OpenStruct.new
        self << normalize_success_args(success_args)
      end

      def to_url name_context=@name_context
        case (target = target(name_context)) 
        when Card
          target.format.path params
        else
          target
        end
      end

      def in_context name_context
        self.name_context = name_context
        self
      end

      def << value
        if value.is_a? Hash
          apply value
        else
          self.target = value
        end
      end

      def redirect
        @redirect.present? ? @redirect : false
      end

      def reload?
        @reload.to_s == "true"
      end

      def []= key, value
        if respond_to? "#{key}="
          send "#{key}=", value
        else
          @params.send "#{key}=", value
        end
      end

      def [] key
        if respond_to? key.to_sym
          send key.to_sym
        else
          @params.send key.to_sym
        end
      end

      def flash message=nil
        @params[:flash] ||= []
        @params[:flash] << message if message
        @params[:flash]
      end

      def params
        @params.marshal_dump
      end

      def session
        Card::Env.session
      end

      private

      def respond_to_missing? method, _include_private=false
        method.match?(/^(\w+)=?$/) || super
      end

      def method_missing method, *args
        if (m = method.match(/^(\w+(=)?)/))
          infer_bracket m[1].to_sym, m[2], args[0]
        else
          super
        end
      end

      def infer_bracket method, assign, val
        args = [method]
        args << val if assign
        @params.send(*args)
      end

      def apply hash
        hash.each_pair do |key, value|
          self[key] = value
        end
      end

      def normalize_success_args success_args
        case success_args
        when nil
          self.mark = "_self"
          {}
        when ActionController::Parameters
          success_args.to_unsafe_h
        else
          success_args
        end
      end
    end
  end
end
