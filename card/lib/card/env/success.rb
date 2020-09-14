class Card
  module Env
    # Success objects
    class Success
      include Card::Env::Location

      attr_accessor :redirect, :name, :name_context, :reload
      attr_writer :params, :card
      attr_reader :id

      def initialize name_context=nil, success_args=nil
        @name_context = name_context
        @new_args = {}
        @params = OpenStruct.new
        self << normalize_success_args(success_args)
      end

      def in_context name_context
        self.name_context = name_context
        self
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

      def << value
        if value.is_a? Hash
          apply value
        else
          self.target = value
        end
      end

      def reload?
        @reload.to_s == "true"
      end

      # TODO: refactor to use cardish
      def mark= value
        case value
        when Integer then @id = value
        when String then @name = value
        when Card then @card = value
        else
          self.target = value
        end
      end

      # @deprecated
      def id= id
        # for backwards compatibility use mark here.
        # id was often used for the card name
        self.mark = id
      end

      def type= type
        @new_args[:type] = type
      end

      def type_id= type_id
        @new_args[:type_id] = type_id.to_i
      end

      def content= content
        @new_args[:content] = content
      end

      def target= value
        @id = @name = @card = nil
        @target = process_target value
      end

      def process_target value
        case value
        when ""                     then ""
        when "*previous", :previous then :previous
        when %r{^(http|/)}          then value
        when /^REDIRECT:\s*(.+)/
          @redirect = true
          process_target Regexp.last_match(1)
        else self.mark = value
        end
      end

      def apply hash
        hash.each_pair do |key, value|
          self[key] = value
        end
      end

      def card name_context=@name_context
        if @card
          @card
        elsif @id
          Card.fetch @id
        elsif @name
          Card.fetch @name.to_name.absolute(name_context), new: @new_args
        end
      end

      def target name_context=@name_context
        card(name_context) ||
          (@target == :previous ? Card::Env.previous_location : @target) ||
          Card.fetch(name_context)
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

      def raw_params
        @params
      end

      def to_url name_context=@name_context
        case (target = target(name_context))
        when Card
          target.format.path params
        else
          target
        end
      end

      def method_missing method, *args
        case method
        when /^(\w+)=$/
          self[Regexp.last_match(1).to_sym] = args[0]
        when /^(\w+)$/
          self[Regexp.last_match(1).to_sym]
        else
          super
        end
      end

      def session
        Card::Env.session
      end
    end
  end
end
