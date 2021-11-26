def followable?
  false
end

def ok_to_read
  left.ok_to_read
end

def history?
  false
end

event :remove_codename, :prepare_to_validate,
      on: :delete,
      when: proc { |c| c.codename.present? } do
  # load file before deleting codename otherwise it will fail later
  attachment
  self.codename = nil
end

format do
  def outputter
    left
  end

  view :not_found do
    return super() unless update_asset_output_live?

    root.error_status = 302
    outputter.update_asset_output_live
  end

  def update_asset_output_live?
    outputter.is_a?(Abstract::AssetOutputter) && !outputter.locked?
  end
end
