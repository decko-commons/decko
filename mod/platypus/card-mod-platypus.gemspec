# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "platypus" do |s, d|
  s.required_ruby_version = ">= 3.0.0"
  s.summary = "support for core developers (platypuses)"
  s.description = ""
  d.depends_on ["fog-aws", "~> 3.10"],
               ["yard",     "~> 0.9"],
               ["rake-hooks", "~> 1.1"]
end
