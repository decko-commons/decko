# -*- encoding : utf-8 -*-

require_dependency "card/version"

def ok_to_read
  true
end

def content
  Card::Version.release
end

# view :core, :raw
