# -*- encoding : utf-8 -*-

require "coffee-script"

include_set Abstract::Script

format :html do
  def ace_mode
    :coffee
  end

  def bare_compile
    true
  end
end

format do
  def bare_compile
    false
  end

  view :core do
    compile_coffee _render_raw
  end

  def compile_coffee script
    ::CoffeeScript.compile script, no_wrap: bare_compile
  rescue StandardError => e
    line_nr = e.to_s.match(/\[stdin\]:(\d*)/)&.capture(0)&.to_i
    line = script.lines[line_nr - 1] if line_nr
    raise Card::Error, "CoffeeScript::Error (#{card.name}): #{e.message}: #{line}"
  end
end
