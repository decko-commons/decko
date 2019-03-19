include_set Abstract::Pointer

format :html do
  view :overview do
    %i[infobar bar box closed titled labeled].map do |view|
      voo.items[:view] = view
      wrap_with :p, [content_tag(:h3, "#{view} items"), render_content]
    end
  end
end
