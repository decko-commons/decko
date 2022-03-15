require "htmlentities"

format do
  def to_text html
    HTMLEntities.new.decode strip_tags(html).to_s
  end

  def nestless_content
    content_obj = content_object card.content
    content_obj.strip_nests
    content_obj.process_chunks
    content_obj.to_s
  end

  view :text_without_nests do
    to_text nestless_content
  end
end

format :text do
  # TODO: override this in cards without html content
  view :core do
    to_text super()
  end
end
