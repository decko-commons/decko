class Cardname
  # methods for the Cardname class.
  module ClassMethods
    # #new skips installation and returns a cached Cardname object when possible
    # @return [Cardname]
    def new obj
      return obj if obj.is_a? self.class

      str = stringify(obj)
      cache[str] ||= super(str)
    end

    # Cardname cache. keys are strings, values are corresponding Cardname objects
    # Note that unlike most decko/card caches, the cardname cache is process-specific
    # and should not need to be reset even with data changes, because Cardname objects
    # are not data-aware.
    #
    # @return [Hash]
    def cache
      @cache ||= {}
    end

    # # reset Cardname cache
    # # @see #cache
    # # @return [Hash]
    # def reset
    #   @cache = {}
    # end

    # true if there are no banned characters
    # @return [Boolean]
    def nothing_banned?
      return @nothing_banned unless @nothing_banned.nil?

      @nothing_banned = banned_array.empty?
    end

    # regular expression for detecting banned characters
    # @return [Regexp]
    def banned_re
      @banned_re ||= /[#{Regexp.escape((banned_array + [joint])).join}]/
    end

    # split string on joint into parts
    # @return [Array]
    def split_parts str
      str.split(/\s*#{JOINT_RE}\s*/, -1)
    end

    private

    def stringify obj
      if obj.is_a?(Array)
        obj.map(&:to_s) * joint
      else
        obj.to_s
      end
    end
  end
end
