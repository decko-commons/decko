# -*- encoding : utf-8 -*-

class FixOldNavbarIssue < Cardio::Migration::Transform
  NEST_REGEP = /\{\{\*navbox\|navbar\}\}/

  def up
    header = "*header".card # name, not codename, is correct here
    return unless header.content.match? NEST_REGEP

    header.update! content: header.content.gsub(NEST_REGEP, "{{:search|search_box}}")
  end
end
