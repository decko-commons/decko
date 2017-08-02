# -*- encoding : utf-8 -*-

require 'active_support/configurable'
require 'active_support/inflector'
require 'htmlentities'
require_relative 'cardname/parts'
require_relative 'cardname/variants'
require_relative 'cardname/contextual'
require_relative 'cardname/predicates'
require_relative 'cardname/manipulate'

class Cardname < Object

  include Parts
  include Variants
  include Contextual
  include Predicates
  include Manipulate

  RUBYENCODING = RUBY_VERSION !~ /^1\.8/
  OK4KEY_RE    = RUBYENCODING ? '\p{Word}\*' : '\w\*'

  include ActiveSupport::Configurable

  config_accessor :joint, :banned_array, :var_re, :uninflect, :params,
                  :session, :stabilize

  Cardname.joint          = '+'
  Cardname.banned_array   = ['/', '~', '|']
  Cardname.var_re         = /\{([^\}]*\})\}/
  Cardname.uninflect      = :singularize
  Cardname.stabilize      = false

  JOINT_RE = Regexp.escape joint

  @@name2nameobject = {} # name cache

  class << self
    def new obj
      return obj if obj.is_a? self.class
      str = stringify obj
      known_name(str) || super(str.strip)
    end

    def known_name str
      @@name2nameobject[str]
    end

    def stringify obj
      if obj.is_a?(Array)
        obj.map(&:to_s) * joint
      else
        obj.to_s
      end
    end

    def banned_re
      %r{#{ (['['] + banned_array << joint) * '\\' + ']' }}
    end

    # Sometimes the core rule "the key's key must be itself" (called "stable" below) is violated
    # eg. it fails with singularize as uninflect method for Matthias -> Matthia -> Matthium
    # Usually that means the name is a proper noun and not a plural.
    # You can choose between two solutions:
    # 1. don't uninflect if the uninflected key is not stable (stabilize = false)
    #    (probably the best choice because you want Matthias not to be the same  as Matthium)
    # 2. uninflect until the key is stable (stabilize = true)
    def stable_uninflect name
      key_one = name.send(Cardname.uninflect)
      key_two = key_one.send(Cardname.uninflect)
      return key_one unless key_one != key_two
      Cardname.stabilize ? stable_uninflect(key_two) : name
    end
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ~~~~~~~~~~~~~~~~~~~~~~ INSTANCE ~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_reader :key, :s
  alias to_s s

  def initialize str
    @s = str.to_s.strip
    @s = @s.encode('UTF-8') if RUBYENCODING
    initialize_parts
    @key = @part_keys.join(self.class.joint)
    @@name2nameobject[str] = self
  end

  def to_name
    self
  end

  def length
    parts.length
  end

  def size
    to_s.size
  end

  def inspect
    "<#{self.class.name} key=#{key}[#{self}]>"
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
end
