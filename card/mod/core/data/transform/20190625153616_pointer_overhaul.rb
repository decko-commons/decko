# -*- encoding : utf-8 -*-

class PointerOverhaul < Cardio::Migration::Transform
  def up
    unless Card::Codename[:mirrored_list]
      update "List", name: "Mirrored List",
                     codename: "mirrored_list"
    end
    unless Card::Codename[:mirror_list]
      update "Listed by", name: "Mirror List",
                          codename: "mirror_list"
    end
    update "Pointer", name: "List", codename: "list" unless Card::Codename[:list]
    Card::Cache.reset_all
    ensure_list_card "list+*input+*type plus right+*options",
                     content: ["List", "Multiselect", "Checkbox", "Filtered list"]

    ensure_list_card "pointer+*input+*type plus right+*options",
                     content: %w[Select Radio]
  end
end
