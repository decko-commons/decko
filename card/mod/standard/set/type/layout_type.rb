# -*- encoding : utf-8 -*-

include_set Type::Html

format :html do
  view :core do
    with_nest_mode :template do
      process_content ::CodeRay.scan(_render_raw, :html).div
    end
  end
end
