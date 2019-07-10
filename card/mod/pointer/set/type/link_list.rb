include_set Abstract::Pointer

def item_names
  reference_chunks.map(&:referee_name)
end

def item_titles
  reference_chunks.map do |chunk|
    chunk.options[:title] || chunk.referee_name
  end
end

format do
  def chunk_list
    :references
  end
end

format :html do
  def editor
    :ace_editor
  end
end
