format :html do
  NEST_OPTIONS = [:view, :title, :show, :hide, :wrap, :help, :variant, :size, :params]
    # Card::View::Options.shark_keys - %i[nest_syntax nest_name items cache]
  view :nest_editor, cache: :never, template: :haml, wrap: :slot do
  end

  def nest_option_name_select
    select_tag "nest_option_name", options_for_select(NEST_OPTIONS)
  end

  def nest_option_value_select
    select_tag "nest_option_value"
  end
end
