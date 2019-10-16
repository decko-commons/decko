require_relative "./file_card_creator/script_card"
require_relative "./file_card_creator/style_card"
require_relative "./file_card_creator/haml_card"
require_relative "./file_card_creator/abstract_file_card"

class Card
  # A Factory class
  # It chooses the class to create the file card according to the given type.
  class FileCardCreator
    CARD_CLASSES = [StyleCard, ScriptCard, HamlCard].freeze

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
