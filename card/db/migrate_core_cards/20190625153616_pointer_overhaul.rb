# -*- encoding : utf-8 -*-

class PointerOverhaul < Card::Migration::Core
  def up
    update "List", name: "Mirrored List", codename: "mirrored_list" unless Card::Codename[:mirrored_list]
    update "Listed by", name: "Mirror List", codename: "mirror_list" unless Card::Codename[:mirror_list]
    update "Pointer", name: "List", codename: "list" unless Card::Codename[:list]
    ensure_code_card "Pointer", type_id: Card::CardtypeID
    ensure_code_card "Link list", type_id: Card::CardtypeID
    Card::Cache.reset_all
    ensure_list_card "list+*input+*type plus right+*options",
                     content: ["List", "Multiselect", "Checkbox", "Filtered list"]

    ensure_list_card "pointer+*input+*type plus right+*options",
                     content: ["Select", "Radio"]


  end
end
