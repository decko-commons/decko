# -*- encoding : utf-8 -*-

class UpdateBootswatchThemesTo4Beta < Card::Migration::Core
  def up
    puts "Updating bootstrap themes ..."
    Skin.themes.each do |theme_name|
      puts theme_name
      Skin.new(theme_name).create_or_update
    end
    update_default_bootstrap
  end

  def update_default_bootstrap
    paths = [Skin.bootstrap_scss_path("functions"),
             Skin.bootstrap_scss_path("variables")]
    puts "Update bootstrap default"
    Skin.new("Bootstrap default")
        .update_scss field_name: "variables", file_name: paths
    puts "Finished"
  end

  class Skin
    require_dependency "card/model/save_helper"
    include ::Card::Model::SaveHelper

    class << self
      def vendor_path
        File.expand_path "../../../vendor", __FILE__
      end

      def bootstrap_scss_path filename
        File.join vendor_path, "bootstrap", "scss", "_#{filename}.scss"
      end

      def themes
        json = File.read File.join(vendor_path, "bootswatch", "api", "4.json")
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
                   subcards: {
                     "+variables" => scss_args([Skin.bootstrap_scss_path("functions"),
                                                   Skin.bootstrap_scss_path("variables"),
                                                   "variables"]),
                     "+style" => scss_args("bootswatch"),
                     "+Image" => thumbnail_args
                   }
    end

    def update_skin
      update_scss file_name: [Skin.bootstrap_scss_path("functions"),
                              Skin.bootstrap_scss_path("variables"),
                              "variables"],
                  field_name: "variables"
      update_scss file_name: "bootswatch", field_name: "style"
      update_tumbnail
    end

    def update_scss file_name:, field_name: file_name
      update_card "#{@skin_name}+#{field_name}", scss_args(file_name)
    end

    def update_tumbnail
      update_card "#{@skin_name}+Image", thumbnail_args
    end

    private

    def scss_args file_name
      paths = Array.wrap(file_name).map { |fn| resource_path(fn) }
      content = paths.map { |p| File.read(p) }.join "\n"
      { type_id: Card::ScssID, content: content }
    end

    def thumbnail_args
      {
        codename: "#{@skin_codename}_image",
        type_id: Card::ImageID,
        mod: :bootstrap, storage_type: :coded,
        image: File.open(resource_path("thumbnail.png"))
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

    def base_resource_dir
      File.join Skin.vendor_path, "bootswatch", @theme_name
      # Card::Migration::Core.data_path "b4_beta_themes/#{@theme_name.downcase.tr(" ","_")}"
    end
  end
end


