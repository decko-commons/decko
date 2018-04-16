module CoreExtensions
  module Hash
    module ClassMethods
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
      # eg. hash.bury(:a, :b, 7) will make sure hash[:a][:b] is eq
      # @return [Hash] with arbitrary depth
      def bury *array
        validate_bury_array! array
        key = array.shift
        if array.size == 1
          self[key] = array.first
        else
          self[key] ||=
          self[key].bury(*array)
        end
        self
      end

      private

      def validate_bury_array! array
        return unless array.find { |a| a.is_a? Hash }
        raise StandardError, "no hashes in bury arguments"
      end
    end
  end
end
