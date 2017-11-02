# -*- encoding : utf-8 -*-

require_dependency "card/version"

def content
  Card::Version.release
end

# view :core, :raw
