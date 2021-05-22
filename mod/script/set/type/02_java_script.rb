# -*- encoding : utf-8 -*-

include_set Abstract::Script

format :js do
  view :core do
    _render_raw
  end
end

format :html do
  view :include_tag do
    javascript_include_tag card.format(:js).render(:source)
  end
end
