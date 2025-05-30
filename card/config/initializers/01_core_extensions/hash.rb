module CoreExtensions
  # extensions for Ruby Hashes
  module Hash
    # extend ruby Hash class
    module ClassMethods
      # nested ruby hashes
      module Nesting
        # create hash with default nested structures
        # @example
        #   h = Hash.new_nested Hash, Array
        #   h[:a] # => {}
        #   h[:b][:c] # => []
        def new_nested *classes
          initialize_nested classes.unshift ::Hash
        end

        def initialize_nested classes, level=0
          return classes[level].new if level == classes.size - 1

          classes[level].new do |h, k|
            h[k] = initialize_nested classes, level + 1
          end
        end
      end
    end

    # special ruby hash merging behavior
    module Merging
      # attach CSS classes
      # @example
      #  {}.css_merge({:class => "btn"}) # => {:class=>"btn"}
      #
      #  h = {:class => "btn"} # => {:class=>"btn"}
      #  h.css_merge({:class => "btn-primary"}) # => {:class=>"btn
      # btn-primary"}
      def css_merge other_hash, separator=" "
        merge(other_hash) do |key, old, new|
          key == :class ? old.to_s + separator + new.to_s : new
        end
      end

      def css_merge! other_hash, separator=" "
        merge!(other_hash) do |key, old, new|
          key == :class ? old.to_s + separator + new.to_s : new
        end
      end

      # merge string values with `separator`
      def string_merge other_hash, separator=" "
        merge(other_hash) do |_key, old, new|
          old.is_a?(String) ? old + separator + new.to_s : new
        end
      end

      def string_merge! other_hash, separator=" "
        merge!(other_hash) do |_key, old, new|
          old.is_a?(String) ? old + separator + new.to_s : new
        end
      end

      # opposite of #dig
      # eg. hash.bury(:a, :b, 7) will make sure hash[:a][:b] equals 7
      # @return [Hash] with arbitrary depth
      def bury *val
        k = val.shift
        validate_bury_key! k
        if val.size == 1
          self[k] = val.first
        else
          self[k] = {} unless self[k].is_a? ::Hash
          self[k].bury(*val)
        end
        self
      end

      private

      def validate_bury_key! key
        [Hash, Array].each do |klass|
          raise ArgumentError, "illegal #{klass} bury argument" if key.is_a? klass
        end
      end
    end
  end
end
