class Cardname
  module Predicates
    # @return true if name has only one part
    def simple?
      part_names if @simple.nil?
      @simple
    end

    # @return true if name has more than one part
    def compound?
      !simple?
    end

    def valid?
      return true if self.class.nothing_banned?

      !parts.find do |pt|
        pt.match self.class.banned_re
      end
    end

    # @return true if name starts with the same parts as `prefix`
    def starts_with_parts? *prefix
      start_name = prefix.to_name
      start_name == self[0, start_name.num_parts]
    end
    alias_method :start_with_parts?, :starts_with_parts?

    # @return true if name ends with the same parts as `prefix`
    def ends_with_parts? *suffix
      end_name = suffix.to_name
      end_name == self[-end_name.num_parts..-1]
    end
    alias_method :end_with_parts?, :ends_with_parts?

    # @return true if name has a chain of parts that equals `subname`
    def include? subname
      subkey = subname.to_name.key
      key =~ /(^|#{JOINT_RE})#{Regexp.quote subkey}($|#{JOINT_RE})/
    end
  end
end
