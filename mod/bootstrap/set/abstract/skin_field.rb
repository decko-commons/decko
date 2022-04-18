event :update_skin_asset_input, :finalize do
  return if !left || left.action # prevent multiple asset input updates

  left.update_asset_input
end
