# -*- encoding : utf-8 -*-

require "coffee-script"

include_set Abstract::AssetFile

def compress_js?
  @minimize
end

format :js do
  view :source do
    if @local
      card.machine_output_url
    else
      source
    end
  end
end

format :html do
  view :javascript_include_tag do
    javascript_include_tag card.machine_output_url
  end
end