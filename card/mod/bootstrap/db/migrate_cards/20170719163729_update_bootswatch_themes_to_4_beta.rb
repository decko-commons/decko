# -*- encoding : utf-8 -*-

class UpdateBootswatchThemesTo4Beta < Card::Migration::Core
  def up
    remove_old_stuff
    ensure_scss "style: bootstrap functions", codename: "style_bootstrap_functions"
    ensure_scss "style: bootstrap variables", codename: "style_bootstrap_variables"
    ensure_scss "style: bootstrap core", codename: "style_bootstrap_core"
    add_icon_cards

    puts "Updating bootstrap themes ..."
    Skin.themes.each do |theme_name|
      puts theme_name
      Skin.new(theme_name).create_or_update
    end
    add_customizable_skin
    update_bootstrap_default
    Card::Cache.reset_all
  end

  def remove_old_stuff
    delete_code_card :bootswatch_shared
    delete_card "bootswatch theme+*right+*structure"
  end

  def add_customizable_skin
    skin = CustomizableSkin.new("customizable bootstrap")
    skin.create_or_update
  end

  def update_bootstrap_default
    ensure_scss "default bootstrap skin+bootswatch theme",
                content: "{{style: bootstrap functions}}{{style: bootstrap variables}}{{style: bootstrap core}}"
  end

  def add_icon_cards
    %w[font_awesome material_icons].each do |name|
      ensure_css name.tr("_", " "), codename: name
      Card["themeless bootstrap skin"].add_item! name.tr("_", " ")
    end
  end

  class Skin
    include ::Card::Model::SaveHelper

    class << self
      def vendor_path
        File.expand_path "../../../vendor", __FILE__
      end

      def bootstrap_scss_path filename
        File.join vendor_path, "bootstrap", "scss", "_#{filename}.scss"
      end

      def themes
        json = File.read File.join(vendor_path, "bootswatch", "docs", "api", "4.json")
        JSON.parse(json)["themes"].map { |theme| theme["name"] }
      end
    end

    def initialize theme_name
      @theme_name = theme_name.downcase
      @skin_name = "#{theme_name} skin"
      @skin_codename = @skin_name.downcase.tr(" ", "_")
    end

    def create_or_update
      Card.exists?(@skin_name) ? update_skin : create_skin
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
      update_tumbnail
    end

    def update_scss file_name:, field_name: file_name
      update_card "#{@skin_name}+#{field_name}", style_args(file_name)
    end

    def update_css file_name:, field_name: file_name
      ensure_card "#{@skin_name}+#{field_name}", style_args(file_name, Card::CssID)
    end

    def update_tumbnail
      update_card "#{@skin_name}+Image", thumbnail_args
    end

    private

    def create_subcard_args
      {
        "+bootswatch theme" => style_args("bootstrap.css", Card::CssID),
        "+Image" => thumbnail_args
      }
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

  class CustomizableSkin < Skin
    def create_subcard_args
      {
        "+bootswatch theme" => {
          type: :scss,
          content: "{{style: bootstrap functions}}{{_left+variables}}{{style: bootstrap core}}{{_left+style}}"
        },
        "+variables" => style_args(Skin.bootstrap_scss_path("variables")),
        "+style" => { type: :scss, content: "// Use this to override bootstrap css\n" }
      }
    end

    def update_skin
      update_scss file_name: Skin.bootstrap_scss_path("variables"), field_name: "variables"
    end
  end
end


