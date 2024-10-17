# Update or create a bootstrap skin
class Skin
  include ::Card::Model::SaveHelper

  class << self
    def vendor_path
      File.expand_path "../../../vendor", __dir__
    end

    def bootstrap_scss_path filename
      File.join vendor_path, "bootstrap", "scss", "_#{filename}.scss"
    end

    def themes
      json = File.read File.join(vendor_path, "bootswatch", "docs", "api", "4.json")
      JSON.parse(json)["themes"].map { |theme| theme["name"] }
    end

    def each
      themes.each do |theme_name|
        skin = Skin.new(theme_name)
        yield skin
      end
    end
  end

  attr_reader :skin_name, :skin_codename, :theme_name

  def initialize theme_name
    @theme_name = theme_name.downcase
    @skin_name = "#{theme_name} skin"
    @skin_codename = @skin_name.downcase.tr(" ", "_")
  end

  def create_or_update
    Card.exist?(@skin_name) ? update_skin : create_skin
  end

  def create_skin
    Card.create! name: @skin_name,
                 codename: @skin_codename,
                 type_id: Card::SkinID,
                 content: "[[themeless bootstrap skin]]\n[[+bootswatch theme]]",
                 subcards: create_subcard_args
  end

  def update_skin
    update_css file_name: "bootstrap.css", field_name: "bootswatch theme"
    # don't update thumbnails since they are stored as coded files in the gem
    # there's a script for doing that
    # update_tumbnail
  end

  def update_scss file_name:, field_name: file_name
    update_card! "#{@skin_name}+#{field_name}", style_args(file_name)
  end

  def update_css file_name:, field_name: file_name
    ensure_args = style_args file_name, Card::CssID
    Card.ensure ensure_args.merge(name: "#{@skin_name}+#{field_name}")
  end

  def update_thumbnail
    Card.ensure name: thumnail_args.merge(name: "#{@skin_name}+Image")
  end

  private

  def create_subcard_args
    { "+bootswatch theme" => style_args("bootstrap.css", Card::CssID) }
  end

  def style_args file_name, type_id=Card::ScssID
    paths = Array.wrap(file_name).map { |fn| resource_path(fn) }
    content = paths.map { |p| File.read(p) }.join "\n"
    { type_id: type_id, content: content }
  end

  def thumbnail_args
    {
      codename: "#{@skin_codename}_image",
      type_id: Card::ImageID,
      mod: :bootstrap, storage_type: :coded,
      image: File.open(thumbnail_path)
    }
  end

  def resource_path resource
    resource = "_#{resource}.scss" unless resource.include? "."
    if resource.include? File::SEPARATOR
      resource
    else
      File.join base_resource_dir, resource
    end
  end

  def thumbnail_path
    File.join Skin.vendor_path, "bootswatch", "docs", @theme_name, "thumbnail.png"
  end

  def base_resource_dir
    File.join Skin.vendor_path, "bootswatch", "dist", @theme_name
  end
end
