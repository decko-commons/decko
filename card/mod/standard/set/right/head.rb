format :html do
  view :head_content do
    process_content render_raw
  end

  view :core do
    with_nest_mode :template do
      process_content ::CodeRay.scan(render_raw, :html).div
    end
  end
end