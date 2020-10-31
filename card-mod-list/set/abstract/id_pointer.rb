# store items as ids, not names

def standardize_item cardish
  if (id = Card.fetch_id cardish)
    "~#{id}"
  else
    Rails.logger.info "no id for '#{cardish}' added to id pointer"
    nil
  end
end

def item_ids args={}
  item_strings(args).map do |item|
    item = standardize_item item unless item.match?(/^~/)
    item.to_s.tr("~", "").to_i
  end.compact
end

def item_names args={}
  item_ids(args).map(&:cardname).compact
end
