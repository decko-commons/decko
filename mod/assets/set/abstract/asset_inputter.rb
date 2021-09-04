card_accessor :asset_input, type_id: Card::PlainTextID

def dependent_asset_inputters
  referers_responding_to :asset_input
end

def outputters
  referers_responding_to :update_file_output
end

def referers_responding_to method_name
  @referers ||= referers
  @referers.filter { |referer| referer.responds_to? method_name }
end

event :asset_input_changed, :finalize, on: :save do
  dependent_asset_inputters.each &:update_asset_input
  outputters.each &:update_file_output
end

def update_asset_input
  asset_output_card.update content: format(input_format).render(input_view)
end

def input_view
  :core
end



