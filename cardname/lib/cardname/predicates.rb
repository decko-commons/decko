class Cardname
  # name methods returning true/false
  module Predicates
    # true if name has only one part
    # @return [Boolean]
    def simple?
      part_names if @simple.nil?
      @simple
    end

    # true if name has more than one part
    # @return [Boolean]
    def compound?
      !simple?
    end

    # true unless name contains banned characters
    # @return [Boolean]
    def valid?
      return true if self.class.nothing_banned?

      !parts.find do |pt|
        pt.match self.class.banned_re
      end
    end

    # +X
    # @return [Boolean]
    def starts_with_joint?
      compound? && parts.first.empty?
    end

    # true if name starts with the same parts as `prefix`
    # @return [Boolean]
    def starts_with_parts? *prefix
      start_name = prefix.to_name
      start_name == self[0, start_name.num_parts]
    end
    alias_method :start_with_parts?, :starts_with_parts?

    # true if name ends with the same parts as `prefix`
    # @return [Boolean]
    def ends_with_parts? *suffix
      end_name = suffix.to_name
      end_name == self[-end_name.num_parts..-1]
    end
    alias_method :end_with_parts?, :ends_with_parts?

    # true if name has a chain of parts that equals `subname`
    # @return [Boolean]
    def include? subname
      subkey = subname.to_name.key
      key =~ /(^|#{JOINT_RE})#{Regexp.quote subkey}($|#{JOINT_RE})/
    end
  end
end
