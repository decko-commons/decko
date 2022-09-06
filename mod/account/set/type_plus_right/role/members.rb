assign_type :list

event :update_role_cache, :finalize do
  Self::Role.update_rolehash(id, item_ids)
end
