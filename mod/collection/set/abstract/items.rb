def recursable_items?
  true
end

def item_type_id
  opt = options_card
  # FIXME: need better recursion prevention
  return unless opt && opt != self

  opt.item_type_id
end
