# -*- encoding : utf-8 -*-

module ScopeHelpers
  def scope_of section
    case section

    when /main card content/
      with_or_without_main_frame ".d0-card-content"

    when /pointer card content/
      with_or_without_main_frame ".d0-card-content > .pointer-list"

    when /main card header/
      with_or_without_main_frame ".d0-card-header"

    when /main card menu/
      "#main > .card-slot > .menu-slot > .card-menu"

    when /main card frame/
      "#main > .card-slot > .d0-card-frame"

    when /main card body/
      with_or_without_main_frame ".d0-card-body"

    else
      raise "Can't find mapping from \"#{section}\" to a scope.\n" \
            "Now, go and add a mapping in #{__FILE__}"
    end
  end

  def with_or_without_main_frame selector
    slot = "#main > .card-slot"
    "#{slot} > .d0-card-frame > #{selector}, #{slot} > #{selector}"
  end
end

World(ScopeHelpers)
