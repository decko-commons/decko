# -*- encoding : utf-8 -*-

class AddRecentSettingSessionCard < Cardio::Migration::Core
  def up
    Card.create!(
      name: "*recent settings",
      codename: "recent_settings",
      type_code: :pointer,
      subcards: {
        "+*self+*options" => { type_code: :search_type,
                               content: '{"type":"setting"}' },
        "+*self+*update" => { content: "[[Anyone]]" },
        "+*self+**create" => { content: "[[Anyone]]" },
        "+*self+**read" => { content: "[[Anyone]]" }
      }
    )
  end
end
