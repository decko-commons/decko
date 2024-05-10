include_set Abstract::IdList

assign_type :list

event :update_role_cache, :finalize do
  Self::Role.update_rolehash(left.id, item_ids)
end
