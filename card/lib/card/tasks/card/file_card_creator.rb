class Card
  class FileCardCreator
    # %w[output_helper abstract_file_card style_card script_card haml_card].each do |f|
    #   require_dependency "card/tasks/card/file_card_creator/#{f}"
    # end

    CARD_CLASSES = [StyleCard, ScriptCard, HamlCard]

    attr_reader :creator

    def initialize mod, name, type, codename, force
      card_class = FileCardCreator.card_class type
      unless card_class
        raise "'#{type}' is not a valid type. "\
              "Please choose between js, coffee, css, scss and haml", :red
      end

      @creator = card_class.new mod, name, type, codename: codename, force: force
    end

    def self.card_class type
      CARD_CLASSES.find { |cc| cc.valid_type? type }
    end

    delegate :create, to: :creator
  end
end
