class Card
  class StyleCardCreator
    def initialize
      @category = :style
    end

    def type_codename
      @type_codename ||= @type.to_sym
    end

    def content_dir
      File.join "lib", "stylesheets"
    end
  end
end