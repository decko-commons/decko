# -*- encoding : utf-8 -*-

require "coderay"
require "uglifier"

include_set Abstract::AssetInputter, input_format: :js

format :js do
  view :compress do
    js = _render_core
    js = compress js
    comment_with_source js
  end

  def comment_with_source js
    "//#{name}\n#{js}"
  end

  def compress input
    Uglifier.compile input
  rescue StandardError => e
    # CoffeeScript is compiled in a view
    # If there is a CoffeeScript syntax error we get the rescued view here
    # and the error that the rescued view is no valid Javascript
    # To get the original error we have to refer to Card::Error.current
    raise Card::Error, compression_error_message(e)
  end

  def compression_error_message e
    if Card::Error.current
      Card::Error.current.message
    else
      "JavaScript::SyntaxError (#{name}): #{e.message}"
    end
  end

  def compress?
    Cardio.config.compress_javascript
  end
end


def clean_html?
  false
end

format do
  def chunk_list
    # turn off autodetection of uri's
    :nest_only
  end

  # def default_nest_view
  #   :raw
  # end
end

format :html do
  def input_type
    :ace_editor
  end

  def ace_mode
    :javascript
  end

  def content_changes action, diff_type, hide_diff=false
    wrap_with(:pre) { super }
  end

  view :core do
    script = card.format(:js).render_core
    process_content highlight(script)
  end

  view :javascript_include_tag do
    javascript_include_tag card.machine_output_url # path(format: :js)
  end

  def highlight script
    ::CodeRay.scan(script, :js).div
  end
end

def diff_args
  { diff_format: :text }
end
