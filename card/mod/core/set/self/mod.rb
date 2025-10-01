include_set Abstract::List

def item_codes
  Cardio.mods.map do |mod|
    "#{mod}_mod"
  end
end

def content
  item_codes.map(&:cardname).compact.to_pointer_content
end

format :html do
  %i[cardtypes settings tasks configurations].each do |view_name|
    view view_name do
      [
        content_tag(:h1, view_name),
        card.all_admin_configs_grouped_by(:category, :mod)[view_name.to_s]
            .map do |(mod, configs)|
          list_section(mod.name, configs.map { |c| c.codename.to_sym })
        end.join("<br/>")
      ]
    end
  end

  view :roles do
    [
      content_tag(:h1, "Roles"),
      card.all_admin_configs_grouped_by(:roles, :category).map do |(role, configs_by_cat)|
        output [
          content_tag(:h2, role.to_sym.cardname),
          configs_by_cat.map do |(cat, configs)|
            list_section cat, configs.map(&:codename)
          end
        ]
      end.join("<br/>")
    ]
  end
end
