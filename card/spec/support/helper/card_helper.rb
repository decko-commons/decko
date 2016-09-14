class Card
  module SpecHelper
    # to be included in Card
    module CardHelper
      module ClassMethods
        def gimme! name, args={}
          Card::Auth.as_bot do
            c = Card.fetch(name, new: args)
            c.putty args
            Card.fetch name
          end
        end

        def gimme name, args={}
          Card::Auth.as_bot do
            c = Card.fetch(name, new: args)
            if args[:content] && c.content != args[:content]
              c.putty args
              c = Card.fetch name
            end
            c
          end
        end

        cattr_accessor :rspec_binding
      end

      def putty args={}
        Card::Auth.as_bot do
          if args.present?
            update_attributes! args
          else
            save!
          end
        end
      end

      # rubocop:disable Lint/Eval
      def method_missing m, *args, &block
        return super unless Card.rspec_binding
        suppress_name_error do
          method = eval("method(%s)" % m.inspect, Card.rspec_binding)
          return method.call(*args, &block)
        end
        suppress_name_error do
          return eval(m.to_s, Card.rspec_binding)
        end
        super
      end
      # rubocop:enable Lint/Eval

      def suppress_name_error
        yield
      rescue NameError
      end

      def format_with_set set, format_type=:base
        set = include_set_in_test_set(set) if set.abstract_set?

        singleton_class.send :include, set
        format = format format_type
        format.singleton_class.send :include, set_format_class(set, format_type)
        yield format
      end

      def set_format_class set, format_type
        format_class = Card::Format.format_class_name format_type
        set.const_get(format_class)
      end

      def include_set_in_test_set set
        if Object.send(:const_defined?, "Card::Set::All::TestSet")
          Object.send :remove_const, Card::Set::Self::TestSet
        end
        eval <<-RUBY
          class ::Card
            module Set
              class Self
                module TestSet
                  extend Card::Set
                  include_set #{set}
                end
              end
            end
          end
        RUBY
        Card::Set::Self::TestSet
      end
    end
  end
end
