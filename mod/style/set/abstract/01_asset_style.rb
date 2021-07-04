# -*- encoding : utf-8 -*-

require "coffee-script"

include_set Abstract::AssetFile

def compress_js?
  @minimize
end

format :css do
  view :source do
    if @local
      card.machine_output_url
    else
      source
    end
  end
end

format :html do
  view :stylesheet_include_tag do
    stylesheet_include_tag card.machine_output_url
  end
end
