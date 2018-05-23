class Cardname
  # naming conventions:
  # methods that end with _name return name objects
  # the same methods without _name return strings
  module Parts
    attr_reader :parts, :part_keys, :simple

    alias_method :to_a, :parts

    def parts
      @parts = Cardname.split_parts s
    end

    def simple
      @simple = parts.size <= 1
    end
    alias simple? simple

    def part_keys
      @part_keys ||= simple ? [simple_key] : parts.map { |p| p.to_name.simple_key }
    end

    def left
      @left ||= simple? ? nil : parts[0..-2] * self.class.joint
    end

    def right
      @right ||= simple? ? nil : parts[-1]
    end

    def left_name
      @left_name ||= left && self.class.new(left)
    end

    def right_name
      @right_name ||= right && self.class.new(right)
    end

    def left_key
      @left_key ||=  simple? ? nil : part_keys[0..-2] * self.class.joint
    end

    def right_key
      @right_key ||= simple? ? nil : part_keys.last
    end

    def parents
      @parents ||= junction? ? [left, right] : []
    end

    def parent_names
      @parent_names ||= junction? ? [left_name, right_name] : []
    end

    def parent_keys
      @parent_keys ||= junction? ? [left_key, right_key] : []
    end

    # Note that all names have a trunk and tag,
    # but only junctions have left and right

    def trunk
      @trunk ||= simple? ? s : left
    end

    def tag
      @tag ||= simple? ? s : right
    end

    def trunk_name
      @trunk_name ||= simple? ? self : left_name
    end

    def tag_name
      @tag_name ||= simple? ? self : right_name
    end

    def part_names
      @part_names ||= parts.map(&:to_name)
    end

    def piece_names
      @piece_names ||= pieces.map(&:to_name)
    end

    # self and all ancestors (= parts and recursive lefts)
    # @example
    #   "A+B+C+D".to_name.pieces
    #   # => ["A", "B", "C", "D", "A+B", "A+B+C", "A+B+C+D"]
    def pieces
      @pieces ||=
        if simple?
          [self]
        else
          junction_pieces = []
          parts[1..-1].inject parts[0] do |left, right|
            piece = [left, right] * self.class.joint
            junction_pieces << piece
            piece
          end
          parts + junction_pieces
        end
    end

    # def + other
    #   self.class.new(parts + other.to_name.parts)
    # end

    def [] *args
      self.class.new parts[*args]
    end

    # full support of array methods caused trouble with `flatten` calls
    # It splits the parts of names in arrays
    # # name parts can be accessed and manipulated like an array
    # def method_missing method, *args, &block
    #   if ARRAY_METHODS.include? method # parts.respond_to?(method)
    #     self.class.new parts.send(method, *args, &block)
    #   else
    #     super
    #   end
    # end
    #
    # def respond_to? method, include_private=false
    #   return true if ARRAY_METHODS.include? method
    #   super || parts.respond_to?(method, include_private)
    # end
  end
end
