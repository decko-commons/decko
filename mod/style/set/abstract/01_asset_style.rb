# -*- encoding : utf-8 -*-

require "coffee-script"

include_set Abstract::AssetFile

def compress?
  @minimize
end
