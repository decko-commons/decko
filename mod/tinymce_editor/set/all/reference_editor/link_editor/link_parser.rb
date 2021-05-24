#! no set module

# Extracts all information needed to generate the link editor form
# from a link syntax string
class LinkParser
  attr_reader :name, :options, :field, :raw

  def self.new link_string
    return super if link_string.is_a? String

    OpenStruct.new(name: "", options: {}, raw: "[[ ]]")
  end

  def initialize link_string
    @raw = link_string
    link = Card::Content::Chunk::Link.new link_string, nil
    init_name link.name
    @options = link.options
  end

  def title
    @options && @options[:title]
  end

  def field?
    @field
  end

  private

  def init_name name
    @field = name.to_name.simple_relative?
    @name = @field ? name.to_s[1..-1] : name
  end
end
