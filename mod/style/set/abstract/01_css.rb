# -*- encoding : utf-8 -*-

require "sassc"
require "benchmark"
require "coderay"

def clean_html?
  false
end

format do
  # def default_nest_view
  #   :raw
  # end

  # turn off autodetection of uri's
  def chunk_list
    :references
  end
end

format :html do
  def input_type
    :ace_editor
  end

  def ace_mode
    :css
  end

  def default_nest_view
    :closed
  end

  view :core do
    # FIXME: scan must happen before process for inclusion interactions to
    # work, but this will likely cause
    # problems with including other css?
    process_content ::CodeRay.scan(_render_raw, :css).div, size: :icon
  end

  def content_changes action, diff_type, hide_diff=false
    wrap_with(:pre) { super }
  end
end

format :css do
  view :import do
    %{\n@import url("#{_render_url}");\n}
  end

  view :compiled do
    compile(_render_core, :nested)
  end

  view :compressed do
    compress(_render_core)
  end

  def comment_with_source css
    "// #{card.name}\n#{css}"
  end

  def compress input
    compress? ? compile(input) : compile(input, :nested)
  end

  # FIXME: method is repeated called with "nested", but there is no handling for it
  def compile input, _style=:compressed
    SassC::Engine.new(input, style: :compressed).render
  rescue StandardError => e
    binding.pry
    raise Card::Error, css_compression_error(e)
  end

  def css_compression_error error
    # scss is compiled in a view
    # If there is a scss syntax error we get the rescued view here
    # and the error that the rescued view is no valid css
    # To get the original error we have to refer to Card::Error.current
    if Card::Error.current
      Card::Error.current.message
    else
      "Sass::SyntaxError (#{card.name}): #{error.message}"
    end
  end

  def compress?
    Cardio.config.compress_assets
  end
end

def diff_args
  { diff_format: :text }
end
