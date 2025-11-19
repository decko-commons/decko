format do
  # turn off autodetection of uri's
  def chunk_list
    :references
  end
end

# format :html do
#   def pointer_items args
#     card.item_names(context: :raw).map do |iname|
#       wrap_item icard, iname, args
#     end
#   end
# end#

format :email_text do
  def email_addresses context
    context ||= self
    card.item_names(context: context.name).map do |name|
      # FIXME: context is processed twice here because pointers absolutize
      # item_names by default while other types can return relative names.
      # That's poor default behavior and should be fixed!
      name = name.to_name.absolute context
      email_address?(name) ? name : email_address_from_card(name, context)
    end.flatten.compact.join(", ")
  end

  def email_address? string
    string =~ /.+@.+\..+/
  end

  def email_address_from_card name, context
    card = Card.fetch name
    card.account&.email || email_addresses_from_card_content(card, context)
  end

  def email_addresses_from_card_content card, context
    subformat(card).contextual_content(context).split(/[,\n]/)
  end
end
