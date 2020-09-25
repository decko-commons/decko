class Card
  # Class for generating CQL based on filter params
  class FilterQuery
    def initialize filter_keys_with_values, extra_cql={}
      @filter_cql = Hash.new { |h, k| h[k] = [] }
      @rules = yield if block_given?
      @rules ||= {}
      @filter_keys_with_values = filter_keys_with_values
      @extra_cql = extra_cql
      prepare_filter_cql
    end

    def add_to_cql key, value
      @filter_cql[key] << value
    end

    def add_rule key, value
      return unless value.present?
      case @rules[key]
      when Symbol
        send("#{@rules[key]}_rule", key, value)
      when Proc
        @rules[key].call(key, value).each do |cql_key, val|
          @filter_cql[cql_key] << val
        end
      else
        send("#{key}_cql", value)
      end
    end

    def to_cql
      @cql = {}
      @filter_cql.each do |cql_key, values|
        next if values.empty?
        case cql_key
        when :right_plus, :left_plus, :type
          merge_using_and cql_key, values
        else
          merge_using_array cql_key, values
        end
      end
      @cql.merge @extra_cql
    end

    private

    def prepare_filter_cql
      @filter_keys_with_values.each do |key, values|
        add_rule key, values
      end
    end

    def merge_using_array cql_key, values
      @cql[cql_key] = values.one? ? values.first : values
    end

    def merge_using_and cql_key, values
      hash = build_nested_hash cql_key, values
      @cql.deep_merge! hash
    end

    # nest values with the same key using :and
    def build_nested_hash key, values
      return { key => values[0] } if values.one?
      val = values.pop
      { key => val, and: build_nested_hash(key, values) }
    end

    def name_cql name
      return unless name.present?
      @filter_cql[:name] = ["match", name]
    end
  end
end
