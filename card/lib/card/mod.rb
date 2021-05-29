class Card
  class Mod
    attr_reader :name, :path, :index

    def self.normalize_name name
      name.to_s.sub(/^card-mod-/, "")
    end

    def initialize name, path, index
      @name = Card::Mod.normalize_name name
      @path = path
      @index = index
    end

    def card_name
      "mod: #{name}"
    end

    def codename
      "mod_#{name}"
    end

    def script_codename
      "#{codename}_script"
    end

    def tmp_dir type
      File.join Card.paths["tmp/#{type}"].first,
                "mod#{'%03d' % (@index + 1)}-#{@name}"
    end

    def public_assets_path
      File.join(@path, "public", "assets")
    end

    def assets_path
      File.join(@path, "assets")
    end

    def ensure_mod_card
      Card::Auth.as_bot do
        unless Card::Codename.exists? codename
          Card.create name: card_name, codename: codename
        end
        ensure_mod_script_card
      end
    end

    def ensure_mod_script_card
      mod_script_card = find_or_create_mod_script_card
      mod_script_card.update_items
      if mod_script_card.item_cards.present?
        Card[:all, :script].add_item! script_codename.to_sym
      else
        mod_script_card.update codename: nil
        mod_script_card.delete update_referers: true
        Card[:all, :script].drop_item! mod_script_card
      end
    end

    def find_or_create_mod_script_card
      if Card::Codename.exists? script_codename
        Card.fetch script_codename.to_sym
      else
        Card.create name: "#{card_name}+*script",
                    type_id: Card::ModScriptAssetsID,
                    codename: script_codename
      end
    end
  end
end