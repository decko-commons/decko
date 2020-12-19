# -*- encoding : utf-8 -*-

class ResponsiveSidebar < Cardio::Migration::Core
  def up
    if (layout = Card.fetch "Default Layout") &&
       layout.updater.id == Card::WagnBotID
      new_content = layout.db_content.gsub "<body>", '<body class="right-sidebar">'
      layout.update! content: new_content
    end
  end
end
