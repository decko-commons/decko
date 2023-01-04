SETTING_OPTIONS = [["Common", :common_rules],
                   ["All", :all_rules],
                   ["Field", :field_related_rules],
                   ["Recent", :recent_rules]].freeze

COMMON_SETTINGS = %i[create read update delete structure default guide].freeze
FIELD_SETTINGS = %i[default help].freeze

def categories setting
  result = [:all]
  result += %i[field recent common].select do |cat|
    category_settings(cat)&.include? setting
  end
  result
end

def selected_setting_category default=:common
  voo&.filter&.to_sym || params[:group]&.to_sym || default
end

def field_settings
  %i[default help input_type content_options content_option_view]
end

# @param val setting category, setting group or single setting
def setting_list val
  category_settings(val) || group_settings(val) || [val]
end

def category_settings cat
  case cat
  when :all, :all_rules
    all_settings
  when :recent, :recent_rules
    recent_settings
  when :common, :common_rules
    visible_setting_codenames & COMMON_SETTINGS
  when :field, :field_related, :field_related_rules
    field_related_settings
  when :nest_editor_field_related
    nest_editor_field_related_settings
  else
    group_settings cat
  end
end

def group_settings group
  visible_settings(group).map(&:codename) if Card::Setting.groups[group]
end

def all_settings
  visible_setting_codenames.sort
end

def nest_editor_field_related_settings
  field_settings
  #  & card.visible_settings(nil, card.prototype_default_type_id).map(&:codename)
end

def field_related_settings
  field_settings # card.visible_setting_codenames &
end

def recent_settings
  recent_settings = Card[:recent_settings].item_cards.map(&:codename).compact
  recent_settings & visible_setting_codenames
end
