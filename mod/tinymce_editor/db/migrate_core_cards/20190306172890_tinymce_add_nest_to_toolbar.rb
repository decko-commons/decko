# -*- encoding : utf-8 -*-

class TinymceAddNestToToolbar < Cardio::Migration::Core
  def up
    content =
      Card[:tiny_mce].content
                     .sub("link | alignleft aligncenter alignright alignjustify",
                          "link nest | ")
    Card.ensure name: :tiny_mce, content: content
  end
end
