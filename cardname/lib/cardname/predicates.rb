class Cardname
  module Predicates
    # @return true if name has more than one part
    def junction?
      !simple?
    end

    #def blank?
    #  s.blank?
    #end#
    #alias empty? blank?

    def valid?
      !parts.find do |pt|
        pt.match self.class.banned_re
      end
    end

    # @return true if name starts with the same parts as `prefix`
    def starts_with? prefix
      start_name = prefix.to_name
      start_name == self[0, start_name.length]
    end
    alias_method :start_with?, :starts_with?

    # @return true if name ends with the same parts as `prefix`
    def ends_with? postfix
      end_name = postfix.to_name
      end_name == self[-end_name.length..-1]
    end
    alias_method :end_with?, :ends_with?

    # @return true if name has a chain of parts that equals `subname`
    def include? subname
      subkey = subname.to_name.key
      key =~ /(^|#{JOINT_RE})#{Regexp.quote subkey}($|#{JOINT_RE})/
    end
  end
end
