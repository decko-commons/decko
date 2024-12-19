class Cardname
  # naming conventions:
  #
  #   - methods that end with _name return {Cardname} objects
  #   - methods that end with _key return {Cardname#key case/space keys}
  #   - methods without _name or _key return Strings
  #
  module Parts
    # the part of a compound name to the left of the rightmost joint.
    # @example
    #     "A".cardname.left -> nil
    #     "A+B".cardname.left -> "A"
    #     "A+B+C".cardname.left -> "A+B"
    #     "A+B+C+D".cardname.left -> "A+B+C"
    # @see #trunk
    # @return [String]
    def left
      left_name&.s
    end

    # @see #left
    # @return [String]
    def left_key
      left_name&.key
    end

    # @see #left
    # @return [Cardname]
    def left_name
      simple? ? nil : self.class.new(part_names[0..-2])
    end

    # for compound cards, an array of the left and right
    # @example
    #     "A".cardname.parents -> []
    #     "A+B".cardname.parents -> ["A", "B"]
    #     "A+B+C".cardname.parents -> ["A+B", "C"]
    #     "A+B+C+D".cardname.parents -> ["A+B+C", "D"]
    # @see #parts
    # @return [Array <String>]
    def parents
      parent_names.map(&:s)
    end

    # @see #parents
    # @return [Array <String>]
    def parent_keys
      parent_names.map(&:key)
    end

    # @see #parents
    # @return [Array <Cardname>]
    def parent_names
      simple? ? [] : [left_name, right_name]
    end

    # for compound cards, each joint separated part
    # @example
    #     "A".cardname.parts -> []
    #     "A+B".cardname.parts -> ["A", "B"]
    #     "A+B+C".cardname.parts -> ["A", "B", "C"]
    #     "A+B+C+D".cardname.parts -> ["A", "B", C", "D"]
    # @see #parents
    # @return [Array <String>]
    def parts
      part_names.map(&:s)
    end
    alias_method :to_a, :parts

    # @see #parts
    # @return [Array <String>]
    def part_keys
      part_names.map(&:key)
    end

    # @see #parts
    # @return [Array <Cardname>]
    def part_names
      @part_names ||= generate_part_names
    end

    # like #left, but returns self for simple cards
    # @example
    #     "A".cardname.trunk -> "A"
    #     "A+B".cardname.trunk -> "A"
    #     "A+B+C".cardname.trunk -> "A+B"
    #     "A+B+C+D".cardname.trunk -> "A+B+C"
    # @see #left
    # @return [String]
    def trunk
      trunk_name.s
    end

    # @see #trunk
    # @return [String]
    def trunk_key
      trunk_name.key
    end

    # @see #trunk
    # @return [Cardname]
    def trunk_name
      simple? ? self : left_name
    end

    # like #right, but returns self for simple cards
    # @see #right
    # @example
    #     "A".cardname.tag -> "A"
    #     "A+B".cardname.tag -> "B"
    #     "A+B+C".cardname.tag -> "C"
    #     "A+B+C+D".cardname.tag -> "D"
    # @return [String]
    def tag
      tag_name.s
    end

    # @see #tag
    # @return [String]
    def tag_key
      tag_name.key
    end

    # @see #tag
    # @return [Cardname]
    def tag_name
      simple? ? self : right_name
    end

    # the part of a compound name to the left of the rightmost joint.
    #
    #     "A".cardname.right -> nil
    #     "A+B".cardname.right -> "B"
    #     "A+B+C".cardname.right -> "C"
    #     "A+B+C+D".cardname.right -> "D"
    # @see #tag
    # @return [String]
    def right
      right_name&.s
    end

    # @see #right
    # @return [String]
    def right_key
      right_name&.key
    end

    # @see #right
    # @return [Cardname]
    def right_name
      simple? ? nil : part_names[-1]
    end

    private

    def generate_part_names
      return blank_part_names if blank?

      parts = Cardname.split_parts s
      @simple = parts.size <= 1
      @simple ? [self] : parts.map(&:to_name)
    end

    def blank_part_names
      @simple = true
      []
    end
  end
end
