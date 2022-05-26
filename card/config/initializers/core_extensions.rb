# -*- encoding : utf-8 -*-

# extend core Ruby object classes

module CoreExtensions
  ::Kernel.include Kernel
  ::Object.include Object
  ::Module.include Module
  ::String.include String
  ::Array.include Array
  ::Hash.include Hash::Merging
  ::Symbol.include PersistentIdentifier
  ::Integer.include PersistentIdentifier
  ::Hash.extend Hash::ClassMethods::Nesting
  ::MatchData.include MatchData
end
