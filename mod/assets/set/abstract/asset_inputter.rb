card_accessor :asset_input, type_id: Card::PlainTextID

def dependent_asset_inputters
  referers_responding_to :asset_input
end

def outputters
  referers_responding_to :update_asset_output
end

def referers_responding_to method_name
  referers.select { |referer| referer.respond_to? method_name }
end

event :asset_input_changed, :finalize, on: :save do
  update_asset_input
  update_after_input_changed
end

event :asset_input_changed_on_delete, :finalize, on: :delete, before: :clear_references do
  update_after_input_changed
end

def update_after_input_changed
  dependent_asset_inputters.each &:update_asset_input
  outputters.each &:update_asset_output
end

def update_asset_input
  asset_input_card.update content: format(input_format).render(input_view)
end

def ensure_asset_input
  update_asset_input if asset_input.blank?
  asset_input
end

def input_view
  :core
end



