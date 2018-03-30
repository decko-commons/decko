# -*- encoding : utf-8 -*-

require 'active_support/configurable'
require 'active_support/inflector'
require 'htmlentities'

class Cardname < String
  require_relative 'cardname/parts'
  require_relative 'cardname/variants'
  require_relative 'cardname/contextual'
  require_relative 'cardname/predicates'
  require_relative 'cardname/manipulate'

  include Parts
  include Variants
  include Contextual
  include Predicates
  include Manipulate

  OK4KEY_RE = '\p{Word}\*'

  include ActiveSupport::Configurable

  config_accessor :joint, :banned_array, :var_re, :uninflect, :params,
                  :session, :stabilize

  Cardname.joint          = '+'
  Cardname.banned_array   = []
  Cardname.var_re         = /\{([^\}]*\})\}/
  Cardname.uninflect      = :singularize
  Cardname.stabilize      = false

  JOINT_RE = Regexp.escape joint

  @@cache = {}

  class << self
    def new obj
      return obj if obj.is_a? self.class
      str = stringify(obj)
      cached_name(str) || super(str)
    end

    def cached_name str
      @@cache[str]
    end

    def reset_cache str=nil
      str ? @@cache.delete(str) : @@cache = {}
    end

    def stringify obj
      if obj.is_a?(Array)
        obj.map(&:to_s) * joint
      else
        obj.to_s
      end
    end

    def banned_re
      banned_chars = (banned_array << joint).join
      /[#{Regexp.escape banned_chars}]/
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
      [:replace].concat bang_methods
    end

    def split_parts str
      str.split(/\s*#{JOINT_RE}\s*/, -1)
    end
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ~~~~~~~~~~~~~~~~~~~~~~ INSTANCE ~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_reader :key

  def initialize str
    @@cache[str] = super str.strip.encode('UTF-8')
  end

  def s
    @s ||= String.new self
  end
  alias to_s s
  alias to_str s

  def to_name
    self
  end

  dangerous_methods.each do |m|
    define_method m do |*args, &block|
      reset
      super(*args, &block)
    end
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
    instance_variables.each do |var|
      instance_variable_set var, nil
    end
  end
end
