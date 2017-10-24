class Cardname
  module Variants
    def simple_key
      return "" if empty?
      decoded
        .underscore
        .gsub(/[^#{OK4KEY_RE}]+/, '_')
        .split(/_+/)
        .reject(&:empty?)
        .map { |key| self.class.stable_key(key) }
        .join('_')
    end

    def url_key
      @url_key ||= part_names.map do |part_name|
        stripped = part_name.decoded.gsub(/[^#{OK4KEY_RE}]+/, ' ').strip
        stripped.gsub(/[\s\_]+/, '_')
      end * self.class.joint
    end

    # safe to be used in HTML as id ('*' and '+' are not allowed),
    # but the key is no longer unique.
    # For example "A-XB" and "A+*B" have the same safe_key
    def safe_key
      @safe_key ||= key.tr('*', 'X').tr self.class.joint, '-'
    end

    def decoded
      @decoded ||= s.index('&') ? HTMLEntities.new.decode(s) : s
    end

    def to_sym
      s.to_sym
    end
  end
end
