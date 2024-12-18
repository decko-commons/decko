# -*- encoding : utf-8 -*-

require "coderay"

include_set Type::Html

event :update_layout_registry, :finalize, on: :update do
  Card::Layout.deregister_layout name
  Card::Layout.register_layout_with_nest name, format
end

format :html do
  view :core do
    with_nest_mode :template do
      process_content CodeRay.scan(_render_raw, :html).div
    end
  end
end
