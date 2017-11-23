class Card
  class ScriptCardCreator
    def initialize mod, name, type
      @category = :script
    end

    def type_codename
      @type_codename ||=
        case @type
        when "js" then
          :java_script
        when "coffee" then
          :coffee_script
        end
    end

    def content_dir
      File.join "lib", "javascript"
    end


  end
end