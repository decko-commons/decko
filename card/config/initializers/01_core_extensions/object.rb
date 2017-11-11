module CoreExtensions
  module Object
    def deep_clone
      case self
      when Fixnum, Bignum, Float, NilClass, FalseClass, TrueClass, Symbol
        # FIXME: Fixnum and Bignum are deprecated in Ruby 2.4 but need to be supported here
        # so long as decko supports older ruby versions
        klone = self
      when Hash
        klone = clone
        each { |k, v| klone[k] = v.deep_clone }
      when Array
        klone = clone
        klone.clear
        each { |v| klone << v.deep_clone }
      else
        klone = clone
      end
      klone.deep_clone_instance_variables
      klone
    end

    def send_unless method, *args, &_block
      (block_given? ? yield : self) || send(method, *args)
    end

    def send_if     method, *args, &_block
      (block_given? ? yield : self) && send(method, *args)
    end

    def to_name
      Card::Name.new self
    end

    def name?
      # Although we want to check for instances of class Card::Name we can't use that
      # class because it is renewed with every request
      # (at least in development mode) but the name cache is persistent.
      # Hence the name objects in the cache are objects of a different instance of the
      # Card::Name class and is_a?(Card::Name) will return false
      self.is_a? Cardname
    end

    def to_viewname
      Card::Name::ViewName.new self
    end

    def deep_clone_instance_variables
      instance_variables.each do |v|
        instance_variable_set v, instance_variable_get(v).deep_clone
      end
    end

    def in? other
      other.include? self
    end
  end
end
