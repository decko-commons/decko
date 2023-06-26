# TODO: We can't detect file removal for folder group

include_set Abstract::List
include_set Abstract::TaskTable

format :html do
  view :core do
    output [
             content_tag(:p, card.description),
             render_settings,
             render_configurations,
             render_cardtypes,
             render_styles,
             render_scripts,
             render_tasks,
             render_depends_on
           ]
  end

  def section title, content
    "<h2>#{title}</h2><p>#{content}</p>"
  end

  def list_section title, items
    content =
      items&.map do |card|
        nest card, view: :bar
      end&.join(" ")
    return unless content.present?

    section title, content
  end

  view :settings do
    list_section "Settings", card.settings
  end

  view :cardtypes do
    list_section "Cardtypes", card.cardtypes
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

def depends_on
  mod&.spec&.dependencies
    &.map { |dep| dep.name }
    .select { |name| name.starts_with? "card-mod" }
    .map { |name| "mod_#{name[8..-1]}" }
end


def tasks
  basket[:tasks].select { |k, v| v[:mod] == modname.to_sym   }
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
  admin_config["cardtypes"]&.map do |setting|
    setting.to_sym
  end
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

def admin_config
  @admin_config ||= load_admin_config
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