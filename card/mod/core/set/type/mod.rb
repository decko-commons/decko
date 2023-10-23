# TODO: We can't detect file removal for folder group

include_set Abstract::List
include_set Abstract::TaskTable

format :html do
  view :core do
    render_views %i[
      description
      settings
      configurations
      cardtypes
      styles
      scripts
      tasks
      depends_on
    ].select {  |name| card.send("has_#{name}?")}
  end

  view :description do
    content_tag(:p, card.description)
  end

  def render_views list
    list.map { |view_name| send("render_#{view_name}") }.compact.join "<br/>"
  end

  view :settings do
    list_section "Settings", card.settings
  end

  view :cardtypes do
    nested_list_section "Cardtypes", card.cardtypes
  end

  view :configurations do
    return unless card.configurations

    card.configurations.map do |category, names|
      list_section "#{category.capitalize} Configuration", names.map { |name| name.to_sym }
    end.join " "
  end

  view :tasks do
    tasks = card.tasks
    return unless tasks.present?

    section "Tasks", task_table(tasks)
  end

  view :styles do
    style = card.fetch :style
    return unless style
    section "Styles", nest(style, view: :core)
  end

  view :scripts do
    style = card.fetch :script
    return unless style
    section "Scripts", nest(style, view: :core)
  end

  view :gem_info do
    return unless card.mod&.spec

    list_section "Depends on", card.depends_on
  end

  view :depends_on do
    list_section "Depends on", card.depends_on
  end
end

def has_settings?
  settings.present?
end

def has_cardtypes?
  cardtypes.present?
end

def has_configurations?
  configurations.present?
end

def has_tasks?
  tasks.present?
end

def has_styles?
  fetch(:style).present?
end

def has_scripts?
  fetch(:script).present?
end

def  has_depends_on?
  mod&.spec&.dependencies.present?
end

def has_description?
  true
end

def depends_on
  mod&.spec&.dependencies
    &.map { |dep| dep.name }
    &.select { |name| name.starts_with? "card-mod" }
    &.map { |name| "mod_#{name[8..-1]}" }
end

def tasks
  basket[:tasks].select { |_k, v| v[:mod] == modname.to_sym   }
end

def settings
  return unless admin_config

  admin_config["settings"]&.map do |setting|
    setting.to_sym
  end
end

def configurations
  return unless admin_config

  admin_config["configurations"]
end

def cardtypes
  return unless admin_config

  config_codenames_grouped_by_title admin_config_section(:cardtypes)
end

def views
  return unless admin_config

  admin_config["views"]
end


def description
  t("#{modname}_mod_description",
    default: mod&.spec&.description.present? ? mod&.spec&.description : mod&.spec&.summary)
end


def modname
  codename.to_s.gsub(/^mod_/, "")
end

def mod
  @mod ||= Cardio::Mod.fetch modname
end

def admin_config_section category
  admin_config_objects_by_category[category.to_s]
end


def admin_config
  @admin_config ||= load_admin_config
end

def admin_config_objects
  @admin_config_objects ||= admin_config.map do |category, values|
    if values.is_a? Hash
      values.map do |subcategory, subvalues|
        create_config_objects mod, category, subcategory, subvalues
      end.flatten
    else
      create_config_objects mod, category, nil, values
    end
  end.flatten
end

def admin_config_objects_by_category
  @admin_config_objects_by_category ||= admin_config_objects.group_by { |config| config.category }
end


def load_admin_config
  return unless admin_config_exists?
  admin_config = YAML.load_file admin_config_path
  return {} unless admin_config # blank manifest
  # validate_manifest manifest
  admin_config
end

def admin_config_exists?
  @admin_config_exists = !admin_config_path.nil? if @admin_config_exists.nil?
  @admin_config_exists
end


def admin_config_path
  @admin_config_path ||= mod&.subpath "config","admin.yml"
end

private

def read_admin_yml
  YAML.safe_load File.read(filename), [Symbol] if File.exist? filename
end