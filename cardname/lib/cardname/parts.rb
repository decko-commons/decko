class Cardname
  # naming conventions:
  # methods that end with _name return name objects
  # the same methods without _name return strings
  module Parts
    def part_names
      @part_names ||= generate_part_names
    end

    def parts
      part_names.map(&:s)
    end
    alias_method :to_a, :parts

    def part_keys
      part_names.map(&:key)
    end

    def trunk_name
      simple? ? self : left_name
    end

    def trunk
      trunk_name.s
    end

    def trunk_key
      trunk_name.key
    end

    def tag_name
      simple? ? self : right_name
    end

    def tag
      tag_name.s
    end

    def tag_key
      tag_name.key
    end

    def parent_names
      simple? ? [] : [left_name, right_name]
    end

    def parents
      parent_names.map(&:s)
    end

    def parent_keys
      parent_names.map(&:key)
    end

    def left_name
      simple? ? nil : self.class.new(part_names[0..-2])
    end

    def left
      left_name&.s
    end

    def left_key
      left_name&.key
    end

    def right_name
      simple? ? nil : part_names[-1]
    end

    def right
      right_name&.s
    end

    def right_key
      right_name&.key
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
