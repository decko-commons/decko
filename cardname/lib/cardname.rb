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
  require "cardname/class_methods"

  include Parts
  include Pieces
  include Variants
  include Contextual
  include Predicates
  include Manipulate
  include Fields
  extend ClassMethods

  cattr_accessor :joint, :banned_array, :var_re, :uninflect, :params, :session, :stabilize

  self.joint          = "+"
  self.banned_array   = []
  self.var_re         = /\{([^}]*\})\}/
  self.uninflect      = :singularize
  self.stabilize      = false

  OK4KEY_RE = '\p{Word}\*'
  JOINT_RE = Regexp.escape joint

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ~~~~~~~~~~~~~~~~~~~~~~ INSTANCE ~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize str
    super str
    strip!
    encode! "UTF-8"
    part_names # populates @part_names and @simple
    decoded # populates @decoded
    key # populates and freezes @key
    freeze
  end

  # simple string version of name
  # @return [String]
  def s
    String.new self
  end
  alias_method :to_s, :s
  alias_method :to_str, :s

  # @return [Cardname]
  def to_name
    self
  end

  # @return [Symbol]
  def to_sym
    s.to_sym
  end

  # the key defines the namespace
  # @return [String]
  def key
    @key ||= generate_key.freeze
  end

  # test for same key
  # @return [Boolean]
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

  # @see #parts
  # @return [Integer]
  def num_parts
    parts.length
  end

  private

  def generate_key
    @simple ? simple_key : part_keys.join(self.class.joint)
  end

  # @return [String]
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
end
