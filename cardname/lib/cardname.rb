# -*- encoding : utf-8 -*-

require "active_support/inflector"
require "htmlentities"

# The Cardname class generalizes the core naming concepts of Decko/Card. The most central
# of these is the idea that compound names can be formed by combining simple names.
#
#
class Cardname < String
  require "cardname/parts"
  require "cardname/pieces"
  require "cardname/variants"
  require "cardname/contextual"
  require "cardname/predicates"
  require "cardname/manipulate"
  require "cardname/fields"

  include Parts
  include Pieces
  include Variants
  include Contextual
  include Predicates
  include Manipulate
  include Fields

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

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ~~~~~~~~~~~~~~~~~~~~~~ INSTANCE ~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_reader :key

  def initialize str
    super str
    strip!
    encode! "UTF-8"
    part_names # populates @part_names and @simple
    decoded # populates @decoded
    key # populates and freezes @key
    freeze
  end

  def s
    String.new self
  end
  alias_method :to_s, :s
  alias_method :to_str, :s
  # alias_method :dup, :clone

  def to_name
    self
  end



  def key
    @key ||= generate_key.freeze
  end

  def == other
    key ==
      case
      when other.respond_to?(:key)     then other.key
      when other.respond_to?(:to_name) then other.to_name.key
      else                                  other.to_s.to_name.key
      end
  end

  # cardname based on part index
  # @return [Cardname]
  def [] *args
    self.class.new part_names[*args]
  end

  # @return [Integer]
  def num_parts
    parts.length
  end

  private

  def generate_key
    @simple ? simple_key : part_keys.join(self.class.joint)
  end
end
