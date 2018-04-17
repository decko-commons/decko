include_set Type::Scss

class << self
  # @param variables [Card, String, Array<Card, String>]
  # @param styles [Card, String, Array<Card, String>]
  def theme_content variables, styles
    [
      pre_variables,
      to_content(variables),
      post_variables,
      to_content(styles)
    ].join "\n"
  end

  def to_content cards_or_strings
    inp = Array.wrap(cards_or_strings)
    inp.flatten.map do |i|
      i.is_a?(Card) ? i.content : i
    end.join "\n"
  end

  def pre_variables
    load_content :style_jquery_ui_smoothness,
                 :style_cards,
                 "style: right sidebar",
                 :font_awesome, :material_icons,
                 :bootstrap_functions
  end

  def post_variables
    load_content :bootstrap_core, :style_bootstrap_cards
  end

  def load_content *names
    cards = names.map { |n| Card[n] }
    cards.compact.map(&:content).join "\n"
  end
end

def content
  Abstract::BootswatchTheme.theme_content variables_scss, bootswatch_scss
end

def variables_scss
  scss_from_theme_file :variables
end

def bootswatch_scss
  scss_from_theme_file :bootswatch
end

def scss_from_theme_file file
  return "" unless (path = ::File.join(source_dir, "_#{file}.scss")) &&
                   ::File.exist?(path)
  ::File.read path
end

def theme_name
  codename.match(/^(.+)_skin$/).capture(0)
end

def source_dir
  @source_dir ||=
    ::File.expand_path "../../../vendor/bootswatch/dist/#{theme_name}", __FILE__
end







