require "htmlentities"

class Cardname
  module Variants
    def simple_key
      return "" if empty?

      decoded
        .underscore
        .gsub(/[^#{OK4KEY_RE}]+/, "_")
        .split(/_+/)
        .reject(&:empty?)
        .map { |key| stable_key(key) }
        .join("_")
    end

    def url_key
      part_names.map do |part_name|
        stripped = part_name.decoded.gsub(/[^#{OK4KEY_RE}]+/, " ").strip
        stripped.gsub(/[\s_]+/, "_")
      end * self.class.joint
    end

    # safe to be used in HTML as id ('*' and '+' are not allowed),
    # but the key is no longer unique.
    # For example "A-XB" and "A+*B" have the same safe_key
    def safe_key
      key.tr("*", "X").tr self.class.joint, "-"
    end

    def decoded
      @decoded ||= s.index("&") ? HTMLEntities.new.decode(s) : s
    end

    def to_sym
      s.to_sym
    end

    private

    def uninflect_method
      self.class.uninflect
    end

    def stabilize?
      self.class.stabilize
    end

    # Sometimes the core rule "the key's key must be itself" (called "stable" below)
    # is violated. For example,  it fails with singularize as uninflect method
    # for Matthias -> Matthia -> Matthium
    # Usually that means the name is a proper noun and not a plural.
    # You can choose between two solutions:
    # 1. don't uninflect if the uninflected key is not stable (stabilize = false)
    # 2. uninflect until the key is stable (stabilize = true)
    def stable_key name
      key_one = name.send uninflect_method
      key_two = key_one.send uninflect_method
      return key_one unless key_one != key_two

      stabilize? ? stable_key(key_two) : name
    end
  end
end
