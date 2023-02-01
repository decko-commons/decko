card_accessor :asset_input, type: :plain_text

def dependent_asset_inputters
  referers_responding_to :asset_input
end

def outputters
  referers_responding_to :update_asset_output
end

def referers_responding_to method_name
  referers.select { |referer| referer.respond_to? method_name }
end

event :asset_input_changed, :finalize,
      on: :save, when: :asset_inputter?, skip: :allowed do
  update_asset_input
end

event :asset_input_changed_on_delete, :finalize,
      on: :delete, when: :asset_inputter?, before: :clear_references do
  update_referers_after_input_changed
end

def update_referers_after_input_changed
  # puts "dependent inputters for #{name}: #{dependent_asset_inputters}"
  # puts "outputters: #{outputters}"

  dependent_asset_inputters.each(&:update_asset_input)
  outputters.each(&:update_asset_output)
end

def update_asset_input
  return unless Codename.exists? :asset_input
  # otherwise the migration that adds the asset_input card fails

  Card::Auth.as_bot do
    asset_input_card.update({})
    update_referers_after_input_changed
  end
end

def asset_input_content
  return render_asset_input_content if virtual?
  update_asset_input if asset_input.blank?
  asset_input
end

def render_asset_input_content
  format(input_format).render(input_view)
end

def input_view
  :core
end

def asset_input_updated_at
  asset_input_card&.updated_at
end

def refresh_asset
  update_asset_input if asset_input_needs_refresh?
end

def asset_input_needs_refresh?
  false
end

# for override
def asset_inputter?
  true
end

format :html do
  def edit_success
    { reload: true }
  end
end
