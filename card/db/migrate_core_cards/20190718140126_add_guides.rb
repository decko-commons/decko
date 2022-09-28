# -*- encoding : utf-8 -*-

class AddGuides < Cardio::Migration
  GUIDE = <<-MD.strip_heredoc
    #### Editing Guide

    This default guide will appear in the full editor view of any card
    without more specific guidance.  You can use it to put forward principles of style,
    rules of conduct, or any other help text you think may be of use to persons editing
    content.

    Guide content can be edited in [[\\*guide\\|\\*guide rules]].
  MD

  def up
    Card.ensure name: "*guide", codename: "guide", type_id: Card::SettingID
    Card::Cache.reset_all
  end
end
