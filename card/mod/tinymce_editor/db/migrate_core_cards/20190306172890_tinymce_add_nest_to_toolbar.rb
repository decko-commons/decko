# -*- encoding : utf-8 -*-

class TinymceAddNestToToolbar < Card::Migration::Core
  def up
    content =
      Card[:tiny_mce].content
                     .sub("link | alignleft aligncenter alignright alignjustify",
                          "link nest | ")
    ensure_card :tiny_mce, content: content
  end
end
