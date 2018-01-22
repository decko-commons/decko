# -*- encoding : utf-8 -*-

class CustomizableSkin < Card::Migration::Core
  def up
    data_dir = File.expand_path("../data/custom_theme", __FILE__)
    skin = CustomSkin.new("customizable bootstrap", data_dir)
    skin.create_or_update
  end

  class CustomSkin
    THEME_FIELDS = %w[colors components spacing cards fonts more]

    include ::Card::Model::SaveHelper

    def initialize theme_name, data_dir
      @theme_name = theme_name.downcase
      @skin_name = "#{theme_name} skin"
      @skin_codename = @skin_name.downcase.tr(" ", "_")
      @data_dir = data_dir
    end

    def create_or_update
      Card.exists?(@skin_name) ? update_skin : create_skin
    end

    private

    def create_skin
      Card.create! name: @skin_name,
                   codename: @skin_codename,
                   type_id: Card::SkinID,
                   content: "[[themeless bootstrap skin]]\n[[+custom theme]]",
                   subcards: create_subcard_args
    end

    def update_skin
      ensure_card @skin_name,
                  content: "[[themeless bootstrap skin]]\n[[+custom theme]]",
                  subcards: create_subcard_args
      THEME_FIELDS.each do |f|
        update_scss_field f
      end
    end

    def update_scss_field field_name
      ensure_card "#{@skin_name}+custom theme+#{field_name}",
                  theme_field_args(field_name)
    end

    def create_subcard_args
      {
        "+custom theme" => {
          type: :scss,
          content: "{{bootstrap: functions}}\n"\
                   "#{theme_field_nests}\n"\
                   "{{bootstrap: core}}\n{{+style|title: style}}",
          subcards: custom_theme_subcard_args.merge(
            "+style" => { type: :scss, content: "// Use this to override bootstrap css\n" }
          )
        }
      }
    end

    def theme_field_args field_name
      {
        type: :scss,
        content: File.read(File.join(@data_dir, "#{field_name}.scss"))
      }
    end

    def custom_theme_subcard_args
      THEME_FIELDS.each_with_object({}) do |name, h|
        h["+#{name}"] =  theme_field_args(name)
      end
    end

    def theme_field_nests
      THEME_FIELDS.map do |f|
        "{{+#{f}|title: #{f}}}"
      end.join
    end
  end
end


