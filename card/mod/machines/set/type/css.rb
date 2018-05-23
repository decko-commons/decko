# -*- encoding : utf-8 -*-

require "sass"
include_set Abstract::Machine
include_set Abstract::MachineInput

store_machine_output filetype: "css"

machine_input do
  compress_css format(format: :css)._render_core
end

def compress_css input
  Sass.compile input, style: :compressed
rescue => e
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
    "Sass::SyntaxError (#{name}): #{error.message}"
  end
end

def clean_html?
  false
end

format do
  # def default_nest_view
  #   :raw
  # end

  def chunk_list # turn off autodetection of uri's
    :references
  end
end

format :html do
  def editor
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
end

def diff_args
  { diff_format: :text }
end
