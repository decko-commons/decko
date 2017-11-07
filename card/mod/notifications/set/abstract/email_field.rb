
def process_email_addresses context_card, format_args, args
  format(format_args).render_email_addresses(args.merge(context: context_card))
end

format do
  def chunk_list  # turn off autodetection of uri's
    :references
  end
end

# format :html do
#   def pointer_items args
#     card.item_names(context: :raw).map do |iname|
#       wrap_item iname, args
#     end
#   end
# end#

format :email_text do
  view :email_addresses, cache: :never do |args|
    context = args[:context] || self
    card.item_names(context: context.name).map do |name|
      # FIXME: context is processed twice here because pointers absolutize
      # item_names by default while other types can return relative names.
      # That's poor default behavior and should be fixed!
      name = name.to_name.absolute context
      email_address?(name) ? name : email_address_from_card(name, context)
    end.flatten.compact.join(", ")
  end

  def email_address? string
    string =~ /.+\@.+\..+/
  end

  def email_address_from_card name, context
    card = Card.fetch name
    card.account&.email || email_addresses_from_card_content(card, context)
  end

  def email_addresses_from_card_content card, context
    card.contextual_content(context, format: :email_text).split(/[,\n]/)
  end
end
