# -*- encoding : utf-8 -*-

require "active_support/inflector"
require "htmlentities"

class Cardname < String
  require "cardname/parts"
  require "cardname/pieces"
  require "cardname/variants"
  require "cardname/contextual"
  require "cardname/predicates"
  require "cardname/manipulate"
  require "cardname/danger"

  include Parts
  include Pieces
  include Variants
  include Contextual
  include Predicates
  include Manipulate
  include Danger

  OK4KEY_RE = '\p{Word}\*'

  cattr_accessor :joint, :banned_array, :var_re, :uninflect, :params, :session, :stabilize

  self.joint          = "+"
  self.banned_array   = []
  self.var_re         = /\{([^}]*\})\}/
  self.uninflect      = :singularize
  self.stabilize      = false

  JOINT_RE = Regexp.escape joint

  class << self
    def new obj
      return obj if obj.is_a? self.class

      str = stringify(obj)
      cached_name(str) || super(str)
    end

    def reset_cache str=nil
      str ? cache.delete(str) : @cache = {}
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

    def cached_name str
      cache[str]
    end

    def stringify obj
      if obj.is_a?(Array)
        obj.map(&:to_s) * joint
      else
        obj.to_s
      end
    end
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ~~~~~~~~~~~~~~~~~~~~~~ INSTANCE ~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_reader :key

  def initialize str
    self.class.cache[str] = super str.strip.encode("UTF-8")
  end

  def s
    String.new self
  end
  alias_method :to_s, :s
  alias_method :to_str, :s

  def to_name
    self
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
    @key ||= part_keys.join(self.class.joint).freeze
  end

  def == other
    key ==
      case
      when other.respond_to?(:key)     then other.key
      when other.respond_to?(:to_name) then other.to_name.key
      else                                  other.to_s
      end
  end
end
