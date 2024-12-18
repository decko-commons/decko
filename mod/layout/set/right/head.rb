require "coderay"

def ok_to_read?
  true
end

format :html do
  view :head_content, cache: :yes do
    process_content render_raw
  end

  view :one_line_content do
    raw_one_line_content
  end

  view :core do
    process_content CodeRay.scan(render_raw, :html).div
  end
end
