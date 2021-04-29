# -*- encoding : utf-8 -*-

require "active_support/inflector"
require "htmlentities"

class Cardname < String
  require_relative "cardname/parts"
  require_relative "cardname/variants"
  require_relative "cardname/contextual"
  require_relative "cardname/predicates"
  require_relative "cardname/manipulate"

  include Parts
  include Variants
  include Contextual
  include Predicates
  include Manipulate

  OK4KEY_RE = '\p{Word}\*'

  cattr_accessor :joint, :banned_array, :var_re, :uninflect, :params,
                 :session, :stabilize

  self.joint          = "+"
  self.banned_array   = []
  self.var_re         = /\{([^\}]*\})\}/
  self.uninflect      = :singularize
  self.stabilize      = false

  JOINT_RE = Regexp.escape joint

  class << self
    def cache
      @cache ||= {}
    end

    def new obj
      return obj if obj.is_a? self.class

      str = stringify(obj)
      cached_name(str) || super(str)
    end

    def cached_name str
      cache[str]
    end

    def reset_cache str=nil
      str ? cache.delete(str) : @cache = {}
    end

    def stringify obj
      if obj.is_a?(Array)
        obj.map(&:to_s) * joint
      else
        obj.to_s
      end
    end

    def nothing_banned?
      return @nothing_banned unless @nothing_banned.nil?

      @nothing_banned = banned_array.empty?
    end

    def banned_re
      @banned_re ||= /[#{Regexp.escape((banned_array + [joint])).join}]/
    end

    # Sometimes the core rule "the key's key must be itself" (called "stable" below) is violated
    # eg. it fails with singularize as uninflect method for Matthias -> Matthia -> Matthium
    # Usually that means the name is a proper noun and not a plural.
    # You can choose between two solutions:
    # 1. don't uninflect if the uninflected key is not stable (stabilize = false)
    # 2. uninflect until the key is stable (stabilize = true)
    def stable_key name
      key_one = name.send(uninflect)
      key_two = key_one.send(uninflect)
      return key_one unless key_one != key_two

      stabilize ? stable_key(key_two) : name
    end

    def dangerous_methods
      bang_methods = String.instance_methods.select { |m| m.to_s.ends_with?("!") }
      %i[replace concat clear].concat bang_methods
    end

    def split_parts str
      str.split(/\s*#{JOINT_RE}\s*/, -1)
    end
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ~~~~~~~~~~~~~~~~~~~~~~ INSTANCE ~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_reader :key

  def initialize str
    self.class.cache[str] = super str.strip.encode("UTF-8")
  end

  def s
    @s ||= String.new self
  end
  alias_method :to_s, :s
  alias_method :to_str, :s

  def to_name
    self
  end

  dangerous_methods.each do |m|
    define_method m do |*args, &block|
      reset
      super(*args, &block)
    end
  end

  def []= index, val
    p = parts
    p[index] = val
    replace self.class.new(p)
  end

  def << val
    replace self.class.new(parts << val)
  end

  def key
    @key ||= part_keys.join(self.class.joint)
  end

  def == other
    other_key =
      case
      when other.respond_to?(:key)     then other.key
      when other.respond_to?(:to_name) then other.to_name.key
      else                                  other.to_s
      end
    other_key == key
  end

  private

  def reset
    self.class.reset_cache s
    instance_variables.each do |var|
      instance_variable_set var, nil
    end
  end
end
