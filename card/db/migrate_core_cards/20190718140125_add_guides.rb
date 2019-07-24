# -*- encoding : utf-8 -*-

class AddGuides < Card::Migration
  GUIDE = <<-MD.strip_heredoc
    #### Editing Guide

    This default guide will appear in the full editor view of any card 
    without more specific guidance.  You can use it to put forward principles of style, 
    rules of conduct, or any other help text you think may be of use to persons editing 
    content.

    Guide content can be edited in [[\*guide\|\*guide rules]].
  MD

  def up
    ensure_card "*guide", codename: "guide", type_id: Card::SettingID
    Card::Cache.reset_all
    ensure_card "*all+*guide", content: GUIDE, type_id: Card::MarkdownID
  end
end
