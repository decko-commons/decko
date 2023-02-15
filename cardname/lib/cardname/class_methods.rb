class Cardname
  module ClassMethods
    def new obj
      return obj if obj.is_a? self.class

      str = stringify(obj)
      cache[str] ||= super(str)
    end

    def reset
      @cache = {}
    end

    def nothing_banned?
      return @nothing_banned unless @nothing_banned.nil?

      @nothing_banned = banned_array.empty?
    end

    def banned_re
      @banned_re ||= /[#{Regexp.escape((banned_array + [joint])).join}]/
    end

    def split_parts str
      str.split(/\s*#{JOINT_RE}\s*/, -1)
    end

    def cache
      @cache ||= {}
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
