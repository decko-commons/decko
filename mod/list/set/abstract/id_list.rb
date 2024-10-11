# store items as ids, not names

def standardize_item cardish
  if (id = Card.id cardish)
    "~#{id}"
  else
    Rails.logger.info "no id for '#{cardish}' added to id pointer"
    nil
  end
end

def item_ids args={}
  seeding_ids do
    item_strings(args).map do |item|
      item = standardize_item item unless item.match?(/^~/)
      item.to_s.tr("~", "").to_i
    end.compact
  end
end

def item_names args={}
  item_ids(args).map(&:cardname).compact
end

def pod_content
  item_names.join "\n"
end

def replace_references _old_name, _new_name
  # noop
end

# override reference creation so there are no referee_keys
# (referee_keys can screw things up for these cards when things get renamed)
def create_references_out
  referee_ids = item_ids
  return if referee_ids.empty?

  values = referee_ids.each_with_object([]) do |rid, vals|
    vals << {
      referer_id: id,
      referee_id: rid,
      referee_key: nil,
      ref_type: "L"
    }
  end

  Reference.insert_in_slices values
end
