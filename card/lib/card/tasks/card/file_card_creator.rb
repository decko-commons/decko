class Card
  class FileCardCreator
    def initialize mod, name, type
      @mod = mod
      @type = type
      @name = remove_prefix name
      creator_class =
        case type
        when :css, :scss then StyleCardCreator
        when :js, :coffee then ScriptCardCreator
        when :haml then HamlCardCreator
        else
          color_puts "'#{type}' is not a valid type. "\
                 "Please choose between js, coffee, css, scss and haml", :red
        end
      @creator = creator_class.new mod, name, type
    end

    def create
      @creator.create
      create_content_file
      create_rb_file
      create_migration_file
    end

    def create_content_file
      write_to_mod content_dir, content_filename do |f|
        content = (card = Card.fetch(name)) ? card.content : ""
        f.puts content
      end
    end

    def create_rb_file
      self_dir = File.join "set", "self"
      self_file = @name + ".rb"
      write_to_mod(self_dir, self_file) do |f|
        f.puts("include_set Abstract::CodeFile")
      end
    end

    def remove_prefix name
      name.sub(/^(?:script|style):?_?\s*/, "")
    end

    def color_puts colored_text, color, text=""
      puts "#{colored_text.send(color.to_s)} #{text}"
    end

    def content_filename
      file_ext = @type == "coffee" ? ".js.coffee" : "." + @type
      @name + file_ext
    end

    def type_id
      "Card::#{type_codename.to_s.camelcase}ID"
    end

    def rule_card_name
      DEFAULT_RULE[@category]
    end
  end
end
