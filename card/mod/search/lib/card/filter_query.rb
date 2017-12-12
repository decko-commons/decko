class Card
  class FilterQuery
    def initialize filter_keys_with_values, extra_wql={}
      @filter_wql = Hash.new { |h, k| h[k] = [] }
      @rules = yield if block_given?
      @rules ||= {}
      @filter_keys_with_values = filter_keys_with_values
      @extra_wql = extra_wql
      prepare_filter_wql
    end

    def add_to_wql key, value
      @filter_wql[key] << value
    end

    def add_rule key, value
      return unless value.present?
      case @rules[key]
      when Symbol
        send("#{@rules[key]}_rule", key, value)
      when Proc
        @rules[key].call(key, value).each do |wql_key, val|
          @filter_wql[wql_key] << val
        end
      else
        send("#{key}_wql", value)
      end
    end

    def to_wql
      @wql = {}
      @filter_wql.each do |wql_key, values|
        next if values.empty?
        case wql_key
        when :right_plus, :left_plus, :type
          merge_using_and wql_key, values
        else
          merge_using_array wql_key, values
        end
      end
      @wql.merge @extra_wql
    end

    private

    def prepare_filter_wql
      @filter_keys_with_values.each do |key, values|
        add_rule key, values
      end
    end

    def merge_using_array wql_key, values
      @wql[wql_key] = values.one? ? values.first : values
    end

    def merge_using_and wql_key, values
      hash = build_nested_hash wql_key, values
      @wql.deep_merge! hash
    end

    # nest values with the same key using :and
    def build_nested_hash key, values
      return { key => values[0] } if values.one?
      val = values.pop
      { key => val,
        and: build_nested_hash(key, values) }
    end

    def name_wql name
      return unless name.present?
      @filter_wql[:name] = ["match", name]
    end

    def project_wql project
      return unless project.present?
      @filter_wql[:referred_to_by] << { left: { name: project } }
    end
  end
end
