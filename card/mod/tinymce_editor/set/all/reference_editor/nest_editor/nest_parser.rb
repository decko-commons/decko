#! no set module

# Extracts all information needed to generate the nest editor form
# from a nest syntax string
class NestParser
  attr_reader :name, :options, :item_options, :raw

  def self.new nest_string, default_view, default_item_view
    return super if nest_string.is_a? String

    OpenStruct.new(name: "", field?: true,
                   options: [[:view, default_view]], item_options: [],
                   raw: "{{+|view: #{default_view}}}")
  end

  def self.new_image name
    OpenStruct.new(name: name, field?: true,
                   options: [%i[view content], %i[size medium]],
                   item_options: [],
                   raw: "{{+#{name}|view: content; size: medium}}")
  end

  def field?
    @field
  end

  def initialize nest_string, _default_view, default_item_view
    @raw = nest_string
    @default_item_view = default_item_view
    nest = Card::Content::Chunk::Nest.new nest_string, nil
    init_name nest.name
    extract_item_options nest.options
    @options = extract_options nest.options
  end

  private

  def init_name name
    @field = name.to_name.simple_relative?
    @name = @field ? name.to_s[1..-1] : name
  end

  def extract_options options
    Card::Set::All::ReferenceEditor::NestEditor::NEST_OPTIONS
      .each_with_object([]) do |key, res|
      next unless options[key]

      if key.in? %i[show hide]
        values = Card::View.normalize_list(options[key])
        res.concat(values.map { |val| [key, val] })
      else
        res << [key, options[key]]
      end
    end
  end

  def extract_item_options options
    @item_options = []
    item_options = options[:items]
    while item_options
      next_item_options = item_options[:items]
      @item_options << extract_options(item_options)
      item_options = next_item_options
    end
    # @item_options << default_item_options
  end

  def default_item_options
    [:view, @default_item_view]
  end
end
