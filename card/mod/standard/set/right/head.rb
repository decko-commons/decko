def ok_to_read
  true
end

format :html do
  view :head_content do
    process_content render_raw
  end

  view :core do
    process_content ::CodeRay.scan(render_raw, :html).div
  end
end
