include_set Abstract::VirtualCache

def virtual_content
  left.assemble_asset_input_content
end

def history?
  false
end

def followable?
  false
end

def chunk_list
  :none
end
