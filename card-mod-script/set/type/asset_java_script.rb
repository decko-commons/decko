# -*- encoding : utf-8 -*-

include_set Type::JavaScript
include_set Abstract::AssetFile

def compress_js?
  @minimize
end

format :js do
  view :source do
    if @local
      machine_output_url
    else
      card.content
    end
  end
end

format :html do

end
