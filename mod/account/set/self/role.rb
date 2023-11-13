class << self
  CACHE_KEY = "ROLEHASH".freeze

  def role_hash
    @role_hash ||= load_rolehash
  end

  def role_ids user_id
    role_hash.each_with_object([]) do |(role_id, member_ids), all_role_ids|
      next unless member_ids.include? user_id
      all_role_ids << role_id
    end
  end

  def update_rolehash role_id, member_ids
    role_hash[role_id] = member_ids
    ::Card.cache.write CACHE_KEY, role_hash
  end

  def clear_rolehash
    @role_hash = nil
  end

  private

  def load_rolehash
    ::Card.cache.fetch(CACHE_KEY) do
      generate_rolehash
    end
  end

  def generate_rolehash
    Auth.as_bot do
      Card.search(left: { type_id: Card::RoleID }, right_id: Card::MembersID)
          .each_with_object({}) do |member_card, hash|
        hash[member_card.left_id] = ::Set.new member_card.item_ids
      end
    end
  end
end
